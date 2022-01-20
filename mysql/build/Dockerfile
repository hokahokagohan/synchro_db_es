FROM mysql:8

RUN apt-get update \
    && apt-get install -y locales 
RUN locale-gen ja_JP.UTF-8 
RUN echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

RUN mkdir /var/log/mysql \
    && chown mysql:mysql /var/log/mysql

ENV LANG="ja_JP.UTF-8" \
    TZ="Asia/Tokyo"

COPY build/my.cnf /etc/mysql/conf.d/my.cnf