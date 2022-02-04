CREATE DATABASE IF NOT EXISTS wikipedia;
USE wikipedia;

CREATE TABLE IF NOT EXISTS jawiki_articles (
  `no` INT NOT NULL,
  `title` TEXT NOT NULL,
  `text` TEXT,
  `creationdate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `refixdate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`no`)
) ENGINE=MyISAM;

-- SET @i=0;

-- /* title,textのない行を読むときにめちゃくちゃwarnings出そう */
-- LOAD DATA LOCAL INFILE "./docker-entrypoint-initdb.d/jawiki-20211227-cirrussearch-content.json" 
--   INTO TABLE jawiki_articles 
--   FIELDS TERMINATED BY "\t" ESCAPED BY "\\"
--   (@json)
--   SET no=(@i:=@i+1), title=JSON_VALUE(@json, "$.title"), text=JSON_VALUE(@json, "$.text");

