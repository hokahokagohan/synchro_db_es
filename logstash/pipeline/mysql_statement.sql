SELECT no, title, text, UNIX_TIMESTAMP(refixdate) AS unix_ts_in_secs 
FROM jawiki_articles 
WHERE (UNIX_TIMESTAMP(refixdate) >= :sql_last_value AND refixdate < NOW()) 
ORDER BY refixdate 
LIMIT 10000