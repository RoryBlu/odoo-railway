#!/bin/bash
set -e

# Map Railway environment variables to Odoo's expected format
export HOST="${ODOO_DATABASE_HOST}"
export USER="${ODOO_DATABASE_USER}"
export PASSWORD="${ODOO_DATABASE_PASSWORD}"

# Set database port separately (Railway uses PORT for HTTP)
export DB_PORT_5432_TCP_PORT="${ODOO_DATABASE_PORT}"

# Call the official Odoo entrypoint with our arguments
exec /entrypoint.sh "$@" \
    --http-interface=0.0.0.0 \
    --http-port="${PORT}" \
    --without-demo=all \
    --proxy-mode \
    --db-filter=.*
