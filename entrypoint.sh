#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done;

echo Database is now available

exec odoo \
    --http-port="${PORT}" \
    --without-demo=all \
    --proxy-mode \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}"
