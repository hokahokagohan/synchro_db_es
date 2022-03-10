SELECT main.no, main.title, main.text, unix_ts_in_secs 
FROM jawiki_articles AS main
INNER JOIN
(
  SELECT no, UNIX_TIMESTAMP(refixdate) AS unix_ts_in_secs
  FROM jawiki_articles 
  WHERE (unix_ts_in_secs > :sql_last_value AND refixdate < NOW()) 
  ORDER BY refixdate 
) AS sub_table
ON sub_table.no = main.no