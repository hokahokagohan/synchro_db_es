# Realtime Synchronize Database on Elasticsearch
頼むンゴねえ

- [Realtime Synchronize Database on Elasticsearch](#realtime-synchronize-database-on-elasticsearch)
  - [Summary](#summary)
- [Environment](#environment)
  - [File Structure](#file-structure)
  - [Preparation](#preparation)
- [References](#references)
- [memo](#memo)
  - [To Do](#to-do)

## Summary

Logstashは定期的(今回の設定は10秒おき)にRDBのデータを確認し、最後に実行した時間とRDBの各レコードの`refixdate`を比較して、追加・更新のあったレコードのみをElasticsearchに反映します。



# Environment 

## File Structure

```
documents/
  ┗preparation.md
elasticsearch/
  ┗build/
      ┗Dockerfile
mysql/
  ┣build/
  ┃  ┣Dockerfile
  ┃  ┣entrypoint.sh
  ┃  ┗my.cnf
  ┣init/    # MySQLのコンテナ起動時に実行されるファイル
  ┃  ┣create_table.sql
  ┃  ┗(jawiki-20211227-cirrussearch-content.json)   # テスト用のデータ
  ┗(mysql_data)     # MySQLと同期してるとこ
logstash/
  ┣build/
  ┃  ┗Dockerfile
  ┣(mysql-connector-java-8.0.28)
  ┃  ┣  ︙
  ┃  ┗(mysql-connector-java-8.0.28.jar) # MySQLコネクタ
  ┣pipeline/
  ┃  ┗log.conf
  ┗index_template.json    # Elasticsearchのインデックス構造を書いたファイル
(mysql.env)    # 環境変数とか
docker-compose.yaml
docker-compose.ms.yaml  # リソース監視する用
README.md
```

## Preparation
- `mysql.env`を作って下記を指定する
    ```
    MYSQL_HOST=jawiki_db
    MYSQL_PORT=3306
    MYSQL_DATABASE=wikipedia
    MYSQL_USER=(適当)
    MYSQL_PASSWORD=(適当)
    MYSQL_ROOT_PASSWORD=(適当)
    ```

- MySQLとLogstashの接続に必要な`MySQLコネクタ`([MySQL :: Download Connector/J](https://dev.mysql.com/downloads/connector/j/))をインストール
   ```
    wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.28.zip
    unzip mysql-connector-java-8.0.28.zip -d logstash/
   ```

---

# References
- [Elasticsearchクラスターのデータベースデータのリアルタイム同期（mysql） - コードワールド](https://www.codetd.com/ja/article/11891206) (最終閲覧日:2022/1/19)
- [LogstashおよびJDBCを使用してElasticsearchとRDBMSの同期を維持する方法 | Elastic Blog](https://www.elastic.co/jp/blog/how-to-keep-elasticsearch-synchronized-with-a-relational-database-using-logstash) (最終閲覧日:2022/1/19)
  
---

# memo
## To Do
- ~~DB上の追加・更新をElasticsearchに反映させる~~
- Logstashのpipelineのstatementがもう少しスマートにならんかなあ
- ~~LogstashとElasticsearchのリソース確認する~~ logstash, esともに2.0GBぐらい常に使ってるっぽい　一番多いのはmysql……
- ~~DB上の削除はES上で反映されないのなんとかなんないかな~~今回は元のDBで削除することがないので考える必要がなさそう
- 無停止でインデックス更新するやつを試す