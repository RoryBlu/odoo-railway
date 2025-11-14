#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done;

echo Database is now available

# Run Odoo without specifying a database to show database manager
exec odoo \
    --http-interface=0.0.0.0 \
    --http-port="${PORT}" \
    --without-demo=all \
    --db-filter=.* \
    --proxy-mode \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}"
