# 備忘_Elasticsearch編

ちゃんこギャルズ

- [備忘_Elasticsearch編](#備忘_elasticsearch編)
    - [「logstash.outputs.elasticsearch Failed to install template {:message=>"Got response code '400' contacting Elasticsearch at URL ...」が出た](#logstashoutputselasticsearch-failed-to-install-template-messagegot-response-code-400-contacting-elasticsearch-at-url-が出た)


### 「[logstash.outputs.elasticsearch][main] Failed to install template {:message=>"Got response code '400' contacting Elasticsearch at URL ...」が出た

    [Unclear and very verbose status 400 messages when Logstash hits a Elasticsearch mapping error during inserts · Issue #333 · logstash-plugins/logstash-output-elasticsearch](https://github.com/logstash-plugins/logstash-output-elasticsearch/issues/333#issuecomment-282274531)

    `curl -XPUT http://{Elasticsearchのアドレス}/_template/{index名} -H 'Content-Type: application/json' -d '{インデックステンプレートのjson中身}'`でエラーの詳細が出る  
    今回はインデックステンプレートの先頭に`"index_patterns": "{インデックス名}"`がなかったのでエラーが出ていた