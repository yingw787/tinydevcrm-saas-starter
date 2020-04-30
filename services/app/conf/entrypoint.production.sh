#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
        sleep 0.1
    done

    echo "PostgreSQL started"
fi

export BASEDIR='/home/app/web'

python ${BASEDIR}/manage.py flush --no-input
python ${BASEDIR}/manage.py migrate
python ${BASEDIR}/manage.py collectstatic --no-input --clear

exec "$@"
