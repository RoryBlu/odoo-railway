#!/bin/bash
set -e

# Save Railway's HTTP port before unsetting PORT
HTTP_PORT="${PORT}"

# Map Railway environment variables to Odoo's expected format
export HOST="${ODOO_DATABASE_HOST}"
export USER="${ODOO_DATABASE_USER}"
export PASSWORD="${ODOO_DATABASE_PASSWORD}"

# Unset PORT so Odoo entrypoint doesn't use it for database port
# The entrypoint will default to 5432 for database
unset PORT

# Call the official Odoo entrypoint with our arguments
exec /entrypoint.sh "$@" \
    --http-interface=0.0.0.0 \
    --http-port="${HTTP_PORT}" \
    --without-demo=all \
    --proxy-mode \
    --db-filter=.*
