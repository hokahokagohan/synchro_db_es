# 備忘_Elasticsearch周り編

ちゃんこギャルズ


- [備忘_Elasticsearch周り編](#備忘_elasticsearch周り編)
  - [Elasticsearch](#elasticsearch)
  - [Logstash](#logstash)

---

## Elasticsearch
**1.【済】「[logstash.outputs.elasticsearch][main] Failed to install template {:message=>"Got response code '400' contacting Elasticsearch at URL ...」が出た**

[Unclear and very verbose status 400 messages when Logstash hits a Elasticsearch mapping error during inserts · Issue #333 · logstash-plugins/logstash-output-elasticsearch](https://github.com/logstash-plugins/logstash-output-elasticsearch/issues/333#issuecomment-282274531)

`curl -XPUT http://{Elasticsearchのアドレス}/_template/{index名} -H 'Content-Type: application/json' -d '{インデックステンプレートのjson中身}'`でエラーの詳細が出る  
今回はインデックステンプレートの先頭に`"index_patterns": "{インデックス名}"`がなかったのでエラーが出ていた

---

## Logstash
**1.【済】「[ERROR][logstash.agent] Failed to execute action {:action=>LogStash::PipelineAction::Create/pipeline_id:main, :exception=>"LogStash::ConfigurationError", :message=>"Expected one of [ \\t\\r\\n], \"#\", \"input\", \"filter\", \"output\" at line 1, column 1 (byte 1)" ...」が出た**

pipelineに使っている`.conf`にホワイトスペースが混じっていたのが原因だった  
VSCodeの拡張機能の[Gremlins](https://marketplace.visualstudio.com/items?itemName=nhoizey.gremlins)を使って削除




**2. 【済】JDBC inputプラグインの"jdbc_page_size"と"jdbc_fetch_size"の違い +JDBC inputの高速化**

あんまりよくわかってないけど以下の認識をもっている  
（有識者の方からご指摘等お待ちしております）

`jdbc_page_size`はSQLのページネーションのサイズを指定するらしいんですが、Logstashではオフセット法（テーブルフルスキャン）が使用されているのでデータ数が大きければ大きいほど遅くなりやすい、らしい。

```
例: jdbc_page_size => 100

実行されるSQL文: 
SELECT * FROM (statementで抽出されるテーブル) LIMIT 100 OFFSET 0 
→ SELECT * FROM (statementで抽出されるテーブル) LIMIT 100 OFFSET 100（登録済100件を読み込むが登録はしない)
→ SELECT * FROM (statementで抽出されるテーブル) LIMIT 100 OFFSET 200（登録済200件を読み込むがry）
                ︙
```

100万件あるデータを1万件ずつ登録するとして、登録を繰り返すにつれ、登録しないのに読み込まなきゃいけないデータもバカスカ増えるというわけなんですね。
そうなってもいい感じのSQL文を書かなきゃだめぽいです。つらいですね。

[jdbc-pagination mysql extremely slow · Issue #307 · logstash-plugins/logstash-input-jdbc](https://github.com/logstash-plugins/logstash-input-jdbc/issues/307)

一方`jdbc_fetch_size`は、クエリ結果をメモリにロードする件数を指定します。  
大きなデータをいっぺんに読み込むようなクエリを書いても、指定件数ずつのみをロードすることによってOutOfMemoryErrorを回避可能なようです。はえ〜。

[JDBC setFetchSize() ではまった話 | TECHSCORE BLOG](https://www.techscore.com/blog/2019/02/27/jdbc-setfetchsize-%E3%81%A7%E3%81%AF%E3%81%BE%E3%81%A3%E3%81%9F%E8%A9%B1/)

DBのメモリに負担をかけないようにするなら`jdbc_fetch_size`を小さめに指定するのが無難なんですかね。

日本語wikipediaの同期に際しては以下のSQL文に修正したらだいぶ速くなりました。

```
SELECT no, title, text, UNIX_TIMESTAMP(refixdate) AS unix_ts_in_secs 
FROM jawiki_articles 
WHERE (UNIX_TIMESTAMP(refixdate) > :sql_last_value AND refixdate < NOW()) 
ORDER BY refixdate ASC
```
  ↓
```
SELECT main.no, main.title, main.text, unix_ts_in_secs 
FROM jawiki_articles AS main 
INNER JOIN 
( 
  SELECT no, UNIX_TIMESTAMP(refixdate) AS unix_ts_in_secs 
  FROM jawiki_articles WHERE ( UNIX_TIMESTAMP(refixdate) > :sql_last_value AND refixdate < NOW()) 
  ORDER BY refixdate ASC 
) AS sub_table 
ON sub_table.no = main.no
```

サブクエリで先に条件に合うnoとrefixdateだけを取り出して並び替え、メインのテーブルとnoで結合しています。  
修正前は全体にORDER BYかけてたのでかなりの時間がかかっていました（それはそう）  
`jdbc_page_size`を10000で指定して、OFFSETが100万を超えても速く動いてます。最高〜〜〜！
