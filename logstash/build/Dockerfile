FROM docker.elastic.co/logstash/logstash:7.16.3

RUN rm -rf /usr/share/logstash/pipeline

COPY ./mysql-connector-java-8.0.28/mysql-connector-java-8.0.28.jar /usr/share/logstash/mysql-connector-java-8.0.28.jar
# COPY ./jawiki_index.json ./jawiki_index.json
