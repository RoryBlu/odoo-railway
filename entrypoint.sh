#!/bin/sh

set -e

# Debug: Print environment variables
echo "DEBUG: ODOO_DATABASE_HOST=${ODOO_DATABASE_HOST}"
echo "DEBUG: ODOO_DATABASE_PORT=${ODOO_DATABASE_PORT}"
echo "DEBUG: ODOO_DATABASE_USER=${ODOO_DATABASE_USER}"

# Default to 5432 if not set
DB_PORT="${ODOO_DATABASE_PORT:-5432}"

echo "Waiting for database at ${ODOO_DATABASE_HOST}:${DB_PORT}..."

while ! nc -z ${ODOO_DATABASE_HOST} ${DB_PORT} 2>&1; do sleep 1; done;

echo "Database is now available"

exec odoo \
    --http-port="${PORT}" \
    --init=all \
    --without-demo=True \
    --proxy-mode \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${DB_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}" \
    --database="${ODOO_DATABASE_NAME}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1
