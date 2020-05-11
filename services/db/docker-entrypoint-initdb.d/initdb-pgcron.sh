#!/bin/sh

set -ex

# Perform all actions as $POSTGRES_USER
export PGUSER="${POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGDATABASE="${POSTGRES_DB}"

echo "shared_preload_libraries = 'pg_cron'" >> /var/lib/postgresql/data/postgresql.conf
echo "cron.database_name = '${POSTGRES_DB}'" >> /var/lib/postgresql/data/postgresql.conf

# Create the 'pg_cron' PostgreSQL extension.
PGPASSWORD=$PGPASSWORD psql -U $PGUSER -d $PGDATABASE <<- EOSQL
CREATE EXTENSION pg_cron;
EOSQL
