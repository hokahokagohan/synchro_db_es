from time import sleep, time
from elasticsearch import Elasticsearch

start_time = time()

es = Elasticsearch('http://localhost:9200/')
INDEX_NAME = 'jawiki_articles'

end_count = 500000
count = 0

while end_count > count:
  es.indices.refresh(index=INDEX_NAME)
  count = int(es.cat.count(index=INDEX_NAME, params={'format':'json'})[0]['count'])
  print(f'{time()- start_time}// {count} registered.' )
  sleep(30)

  
es.close()
print(f'complete. {time()- start_time}')