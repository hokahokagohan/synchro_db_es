# Preparation

- [Preparation](#preparation)
  - [データベースの準備](#データベースの準備)
    - [既存のデータベースを使用する場合](#既存のデータベースを使用する場合)
    - [新規にデータベースを作成する場合](#新規にデータベースを作成する場合)
  - [Logstashの準備](#logstashの準備)
  - [Elasticsearchの準備](#elasticsearchの準備)
- [References](#references)


## データベースの準備
### 既存のデータベースを使用する場合
1. `.env`ファイルを作成し、下記の設定を入力します。
    ```
    MYSQL_HOST=(MySQLのホスト)
    MYSQL_PORT=(MySQLのポート)
    MYSQL_DATABASE=(DB名)
    MYSQL_USER=(ログインするユーザー名)
    MYSQL_PASSWORD=（MYSQL_USERのパスワード）
    MYSQL_ROOT_PASSWORD=（rootのパスワード）
    ```
    ※LogstashからMySQLに接続する際、SELECT以上の権限を持つユーザーでログインする必要があります。root以外のユーザーでログインするときは`logstash/pipeline/log.conf`の`jdbc_user`と`jdbc_password`を変更してください。この場合MYSQL_ROOT_PASSWORDは記載不要です。

### 新規にデータベースを作成する場合
1. `mysql.env`ファイルを作成し、下記の設定を入力します
    ```
    MYSQL_HOST=mysql
    MYSQL_PORT=3306
    MYSQL_DATABASE=wikipedia
    MYSQL_USER=(適当)
    MYSQL_PASSWORD=（適当）
    MYSQL_ROOT_PASSWORD=（適当）
    ```

2. テスト用データをインストールします。
    ```
    wget -P https://dumps.wikimedia.org/other/cirrussearch/current/jawiki-20211227-cirrussearch-content.json.gz
    gunzip jawiki-20211227-cirrussearch-content.json.gz 
    ```

3. `docker-compose up --build`のあとに`python/register_db.py`を実行します。
    ```
    python python/register_db.py
    ```

## Logstashの準備

1. MySQLとLogstashの接続に必要な`MySQLコネクタ`([MySQL :: Download Connector/J](https://dev.mysql.com/downloads/connector/j/))をインストールします。解凍後の.jarはLogstashの中に置きます。
   ```
    wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.28.zip
    unzip mysql-connector-java-8.0.28.zip -d logstash/
   ```
2. 

## Elasticsearchの準備


# References
<<<<<<< HEAD
- [APIから取得したJSONをとりあえずMySQL8.0に入れてJSON_TABLE()でどうにかする - 主夫ときどきプログラマ](https://masayuki14.hatenablog.com/entry/2018/10/17/170000) (最終閲覧日:2022/1/19)
- [MySQLでJSONを扱う - Qiita](https://qiita.com/abcb2/items/8affae03caa3e94068b5) (最終閲覧日:2022/1/19)
- [MySQL で CSV, Json データ読み込み - Qiita](https://qiita.com/kkdd/items/eff48e26ed5df03c090b) (最終閲覧日:2022/1/26)
=======
>>>>>>> monitor_rsrc
