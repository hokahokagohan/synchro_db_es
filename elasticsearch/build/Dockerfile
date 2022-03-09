FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.3

RUN elasticsearch-plugin install analysis-kuromoji \
    && elasticsearch-plugin install analysis-icu \
    # 監視のときにPrometheusを使う場合に必要
    && elasticsearch-plugin install -b https://github.com/vvanholl/elasticsearch-prometheus-exporter/releases/download/7.16.3.0/prometheus-exporter-7.16.3.0.zip