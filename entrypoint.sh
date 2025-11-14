#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done;

echo Database is now available

# Run Odoo with config file and dynamic PORT from Railway
# Config file (/etc/odoo/odoo.conf) handles most settings
exec odoo \
    -c /etc/odoo/odoo.conf \
    --http-port="${PORT}" \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}"
