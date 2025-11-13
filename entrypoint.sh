#!/bin/sh
set -e

# Fix permissions on volume mount (Railway mounts volumes after build)
echo "Fixing /var/lib/odoo permissions..."
chown -R odoo:odoo /var/lib/odoo 2>/dev/null || true

# Use postgres.railway.internal for private network (faster and more reliable)
DB_HOST="postgres.railway.internal"
DB_PORT="5432"

echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
while ! nc -z ${DB_HOST} ${DB_PORT} 2>&1; do sleep 1; done
echo "Database is now available"

# Start Odoo with command-line configuration
exec odoo \
    --http-port="8069" \
    --proxy-mode \
    --db_host="${DB_HOST}" \
    --db_port="${DB_PORT}" \
    --db_user="${USER}" \
    --db_password="${PASSWORD}" \
    --database="${POSTGRES_DB}" \
    --smtp="${MAILGUN_SMTP_HOST}" \
    --smtp-port="${MAILGUN_SMTP_PORT}" \
    --smtp-user="${MAILGUN_SMTP_USER}" \
    --smtp-password="${MAILGUN_SMTP_PASSWORD}" \
    --email-from="${MAILGUN_EMAIL_FROM}"
