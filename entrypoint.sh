#!/bin/sh
set -e

# Fix permissions on volume mount (Railway mounts volumes after build)
echo "Fixing /var/lib/odoo permissions..."
chown -R odoo:odoo /var/lib/odoo 2>/dev/null || true

echo "Starting Odoo..."

# Start Odoo with command-line configuration
# Odoo handles database connection retries automatically
exec odoo \
    --http-port="8069" \
    --proxy-mode \
    --db_host="${HOST}" \
    --db_port="5432" \
    --db_user="${USER}" \
    --db_password="${PASSWORD}" \
    --database="${POSTGRES_DB}" \
    --smtp="${MAILGUN_SMTP_HOST}" \
    --smtp-port="${MAILGUN_SMTP_PORT}" \
    --smtp-user="${MAILGUN_SMTP_USER}" \
    --smtp-password="${MAILGUN_SMTP_PASSWORD}" \
    --email-from="${MAILGUN_EMAIL_FROM}"
