# 備忘_Elasticsearch周り編

ちゃんこギャルズ


- [備忘_Elasticsearch周り編](#備忘_elasticsearch周り編)
  - [Elasticsearch](#elasticsearch)
  - [Logstash](#logstash)

## Elasticsearch
*「[logstash.outputs.elasticsearch][main] Failed to install template {:message=>"Got response code '400' contacting Elasticsearch at URL ...」が出た*

[Unclear and very verbose status 400 messages when Logstash hits a Elasticsearch mapping error during inserts · Issue #333 · logstash-plugins/logstash-output-elasticsearch](https://github.com/logstash-plugins/logstash-output-elasticsearch/issues/333#issuecomment-282274531)

`curl -XPUT http://{Elasticsearchのアドレス}/_template/{index名} -H 'Content-Type: application/json' -d '{インデックステンプレートのjson中身}'`でエラーの詳細が出る  
今回はインデックステンプレートの先頭に`"index_patterns": "{インデックス名}"`がなかったのでエラーが出ていた

---

## Logstash
*「[ERROR][logstash.agent] Failed to execute action {:action=>LogStash::PipelineAction::Create/pipeline_id:main, :exception=>"LogStash::ConfigurationError", :message=>"Expected one of [ \\t\\r\\n], \"#\", \"input\", \"filter\", \"output\" at line 1, column 1 (byte 1)" ...」が出た*

pipelineに使っている`.conf`にホワイトスペースが混じっていたのが原因  
VSCodeの拡張機能の[Gremlins](https://marketplace.visualstudio.com/items?itemName=nhoizey.gremlins)を使って削除



