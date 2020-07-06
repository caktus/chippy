#!/bin/bash
set -e

wait_time=3
max_waits=10

count=0
until psql $DATABASE_URL -c '\l' ; do
    count=`expr $count + 1`
    if [ $count -ge $max_waits ] ; then
      >&2 echo "Giving up on Postgres, could not reach at $DATABASE_URL"
      exit 1
    fi
    >&2 echo "Postgres is unavailable - sleeping ($count)"
    sleep $wait_time
done

>&2 echo "Postgres is up - continuing"

if [ "x$MIGRATE" = 'xon' ]; then
    echo Migrating the DB
    bin/chippy eval "Chippy.Release.migrate"
    echo Migration complete
fi

exec "$@"
