#!/bin/sh

set -e

# Railway's internal PostgreSQL hostname
# If ODOO_DATABASE_HOST is empty, use Railway's internal network
DB_HOST="${ODOO_DATABASE_HOST:-postgres.railway.internal}"
DB_PORT="${ODOO_DATABASE_PORT:-5432}"

echo "Connecting to database at ${DB_HOST}:${DB_PORT}..."

while ! nc -z ${DB_HOST} ${DB_PORT} 2>&1; do sleep 1; done;

echo "Database is now available"

exec odoo \
    --http-port="${PORT}" \
    --init=all \
    --without-demo=True \
    --proxy-mode \
    --db_host="${DB_HOST}" \
    --db_port="${DB_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}" \
    --database="${ODOO_DATABASE_NAME}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1
