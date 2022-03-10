import json
from time import time

import mysql.connector as mydb

connector = mydb.connect(
  host='localhost',
  port='3306',
  user='mysql',
  password='mysql',
  database='wikipedia',
  auth_plugin='mysql_native_password'
)

cursor = connector.cursor()

def commit(connector, cursor):
  cursor.close()
  connector.commit()
  return connector.cursor()
  

sql = ('INSERT INTO jawiki_articles(no, title, text) VALUES(%s, %s, %s);')

docs = []
count = 1

start_time = time()
with open('python/jawiki-20211227-cirrussearch-content.json', 'r') as f:
  for line in f:
    json_line = json.loads(line)
    if 'index' not in json_line:
      doc = json_line
      docs.append((count, doc['title'], doc['text']))
      count += 1
      
      # 1000件ごとにバルクインサート
      if count % 1000 == 0:
        try:
          cursor.executemany(sql, docs)
          cursor = commit(connector, cursor)
        except Exception as err:
          print(err)
        
        docs = []
        print(f'{count} docs have registerd.')
    
  if docs:
    try:
      cursor.executemany(sql, docs)
      cursor = commit(connector, cursor)
    except Exception as err:
      print(err)
    print(f'{count} docs have registered.')
  
connector.close()
cursor.close()

print(f'time: {float(time()- start_time):.5f}')
print('Complete.')

import gc
gc.collect()