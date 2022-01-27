/* ファイルからデータを読み込むときのおまじない① */
SET PERSIST local_infile=1;

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

/* title,textのない行を読むときにめちゃくちゃwarnings出そう */
LOAD DATA LOCAL INFILE "./docker-entrypoint-initdb.d/jawiki-20211227-cirrussearch-content.json" 
  INTO TABLE jawiki_articles
  FIELDS TERMINATED BY '\\t'
  (@json)
  SET no=(@i:=@i+1), title=CAST(JSON_EXTRACT(@json, '$.title')), text=CAST(JSON_EXTRACT(@json, '$.text'));

