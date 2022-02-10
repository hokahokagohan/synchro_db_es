#! /bin/sh

docker-compose up --build

if ["$DATABASE" = "mysql"]
then
  echo "Waiting for MySQL..."
  while ! nc -z "localost" $MYSQL_PORT; do
    sleep 1
  done
  echo "MySQL started"
fi

python python/register_db.py