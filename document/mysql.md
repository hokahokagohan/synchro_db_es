# JSONファイルからDockerのMySQLにデータをインポートした
PythonからMySQLのAPI叩いたほうがややこしくないけどPythonを使いたくないときもある（ない）

## まえがき

JSONファイルからMySQL上にデータを読み出したかったのでSQL叩いたのにデータが登録されてない。  
どうもエラーが起きているようだが`docker logs`ではエラーの詳細が出てこない……。



## :序

[MySQL :: MySQL 5.6 リファレンスマニュアル :: 13.2.6 LOAD DATA INFILE 構文](https://dev.mysql.com/doc/refman/5.6/ja/load-data.html)

初期データをファイルから投入する場合に使えそうです。便利。  
DockerのMySQLでは初回起動時に`docker-entrypoint-initdb.d`以下にある.sql/.shを実行してくれるとのことなので、これも利用しようと下記のように書きました。

```
# docker-compose.yaml

services:
  mysql:
    container_name: jawiki_db
    build:
      context: ./mysql/
      dockerfile: build/Dockerfile
    # MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, MYSQL_ROOT_PASSWORDを設定したファイルを指定
    env_file: mysql.env   
    volumes:
      - ./mysql/init:/docker-entrypoint-initdb.d
      - mysql_data:/var/lib/mysql
    ports:
      - 3306:3306
    # 文字コードを触っています
    command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

volumes:
  mysql_data:
```

```
# Dockerfile

FROM mysql:8

RUN apt-get update \
    && apt-get install -y locales 
RUN locale-gen ja_JP.UTF-8 
RUN echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

RUN mkdir /var/log/mysql \
    && chown mysql:mysql /var/log/mysql \
    && chmod +x -R /var/lib/mysql

ENV LANG="ja_JP.UTF-8" \
    TZ="Asia/Tokyo"
```

```
# 1_create_table.sql

CREATE DATABASE IF NOT EXISTS wikipedia;
USE wikipedia;

CREATE TABLE IF NOT EXISTS jawiki_articles (
  `no` INT NOT NULL,
  `title` LONGTEXT NOT NULL,
  `text` LONGTEXT,
  `creationdate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `refixdate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`no`)
) ENGINE=InnoDB;

SET @i=0;

LOAD DATA LOCAL INFILE "./docker-entrypoint-initdb.d/jawiki-20211227-cirrussearch-content.json" 
  INTO TABLE jawiki_articles
  FIELDS TERMINATED BY '\\t'
  (@json)
  SET no=(@i:=@i+1), title=JSON_EXTRACT(@json, '$.title'), text=JSON_EXTRACT(@json, '$.text');
```

ファイルの構成は以下
```
mysql/
  ┣build/
  ┃  ┣my.cnf  # 主に文字コードの設定を書いた
  ┃  ┗Dockerfile
  ┗init/
      ┣1_create_table.sql
      ┗jawiki-20211227-cirrussearch-content.json  # 今回投入するデータ
docker-compose.yaml
```

`docker-compose up`で起動します。

```
ERROR 2068 (HY000) at line 18: LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.
```

弾かれました。

> LOCAL は、サーバーとクライアントの両方がそれを許可するように構成されている場合にのみ機能します。たとえば、mysqld が --local-infile=0 で起動された場合、LOCAL は機能しません。[セクション6.1.6「LOAD DATA LOCAL のセキュリティーの問題」](https://dev.mysql.com/doc/refman/5.6/ja/load-data-local-security.html)を参照してください。

`LOAD DATA LOCAL INFILE`として使用する場合はサーバーとクライアント側で許可が必要だそうです。  
`LOCAL`を外せば済むんか？と思って外してみると今度は「`secure-file-priv`オプションが設定されてるのでダメ」という怒られが発生しました。  
素直にはじめに言われた許可設定をします。

- サーバー側で`--enable-local-infile`か`--local-infile=1`を設定
    ```
    # docker-compose.yaml
        ︙
      command: mysqld --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --local-infile=1
    ```
- クライアント側で`local_infile=1`を設定
    ```
    # 1_create_table.sql
    CREATE DATABASE IF NOT EXISTS wikipedia;
    USE wikipedia;

    SET PERSIST local_infile=1;
    
    CREATE TABLE IF NOT EXISTS jawiki_articles (
        ︙
    ```

参考:[日々の覚書: MySQL 8.0でLOAD DATA LOCAL INFILEが "ERROR 1148 (42000): The used command is not allowed with this MySQL version" または "Error: 3948. Loading local data is disabled; this must be enabled on both the client and server sides" で失敗する時](https://yoku0825.blogspot.com/2018/07/mysql-80load-data-local-infile-error.html)

頼むぞ！

……と実行したら先ほどと同じエラーが出ました。  
MySQLに入って`SHOW VARIABLES LIKE '%local%'`を叩くと`local_infile=1`になっていたので、サーバー側の設定はできているようです。  
クライアント側で直接設定しようと`SET PERSIST local_infile=1;`を実行すると下記のエラーが。

```
ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER or SYSTEM_VARIABLES_ADMIN privilege(s) for this operation
```

実行ユーザーにlocal_infileを設定する権限がないようです。南無……。

rootユーザーで実行するのが手っ取り早そうですが、rootで入ったまま起動させておくのも危ない気がするので別の方法を探していたところ、公式にそれっぽい答えがありました。

> オプションファイルから [client] グループを読み取る Perl スクリプトまたはその他のプログラムで LOAD DATA LOCAL を使用する場合、local-infile=1 オプションをそのグループに追加できます。ただし、local-infile を認識しないプログラムで問題が発生しないようにするために、loose- プリフィクスを使用してこれを指定します。  
> --- [セクション6.1.6「LOAD DATA LOCAL のセキュリティーの問題」](https://dev.mysql.com/doc/refman/5.6/ja/load-data-local-security.html)

オプションファイルから設定すればいいのか〜なるほど！

```
# my.cnf

    ︙
[client]
loose-local-infile=1
```

[mysqladmin: [Warning] unknown variable 'loose-local-infile=1'.](https://gihyo.jp/dev/serial/01/mysql-road-construction-news/0033)が出ますが気にしなくて良さそうです。

`my.cnf`に上記を追記して実行したところ順調に進んでいます。これで解決か……！？

## :破

順調に進んでいるかと思いきや、途中でMySQLコンテナが落ちてしまいました。

```
ERROR 3141 (22032) at line 18: Invalid JSON text in argument 1 to function json_extract: "Invalid encoding in string." at position 6038.
``` 

調べた限りで考えられる原因は以下の３つでした。

1. JSON_EXTRACTの返り値とカラムの型が一致してない
2. JSONファイルのテキストにエスケープ文字が入ってしまっている
3. 突っ込むデータの容量がデカすぎる

1.が一番怪しいな〜と思い、ドキュメント等をいろいろ読み漁っていると、`JSON_EXTRACT`の返り値がJSON型であることを知りました。へえ……。~~勝手にキャストとかしてくれてると思ってた。~~  
また、JSON_EXTRACTの返り値がダブルクォートを含むため、キャストするとダブルクォートがダブるという事態を避けるために`JSON_VALUE`に変更します。




## :Q


## シン:||




# References