#!/bin/sh

set -e

# Set default PORT if not provided by Railway
PORT=${PORT:-8069}

echo "Starting Odoo on port ${PORT}"

# Check if we're using the postgres user (which Odoo blocks for security)
if [ "${ODOO_DATABASE_USER}" = "postgres" ]; then
    echo "WARNING: Using 'postgres' as database user is not allowed by Odoo for security reasons."
    echo "Please create a dedicated database user. For example:"
    echo "  CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';"
    echo ""
    echo "Then update your environment variables:"
    echo "  ODOO_DATABASE_USER=odoo"
    echo "  ODOO_DATABASE_PASSWORD=your-secure-password"
    exit 1
fi

echo "Database user: ${ODOO_DATABASE_USER}"
echo "Waiting for database..."

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done; 

echo "Database is now available"

exec odoo \
    --http-port="${PORT}" \
    --init=all \
    --without-demo=True \
    --proxy-mode \
    --data-dir="/var/lib/odoo" \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}" \
    --database="${ODOO_DATABASE_NAME}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1