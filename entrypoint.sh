#!/bin/sh

set -e

# Wait for Railway's private network DNS to resolve
echo "Waiting for private network DNS..."
sleep 3

# Railway's internal PostgreSQL hostname for postgres-ssl service
# If ODOO_DATABASE_HOST is empty, use Railway's internal network
DB_HOST="${ODOO_DATABASE_HOST:-postgres-ssl.railway.internal}"
DB_PORT="${ODOO_DATABASE_PORT:-5432}"

echo "Connecting to database at ${DB_HOST}:${DB_PORT}..."

while ! nc -z ${DB_HOST} ${DB_PORT} 2>&1; do sleep 1; done;

echo "Database is now available"

echo "DEBUG: DB_USER=${ODOO_DATABASE_USER}"
echo "DEBUG: DB_NAME=${ODOO_DATABASE_NAME}"
echo "DEBUG: DB_PASSWORD length: $(echo -n "${ODOO_DATABASE_PASSWORD}" | wc -c)"
echo "DEBUG: PORT=${PORT}"

# Create odoo user if it doesn't exist and set password
echo "Ensuring odoo user exists and password is set correctly..."
PGPASSWORD='zAaUIpcupYvQtHcLGiAQhrWbhhMtrZtG' psql -h "${DB_HOST}" -U postgres -d railway << EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'odoo') THEN
        CREATE USER odoo WITH CREATEDB PASSWORD '${ODOO_DATABASE_PASSWORD}';
        GRANT ALL PRIVILEGES ON DATABASE railway TO odoo;
    ELSE
        ALTER USER odoo WITH PASSWORD '${ODOO_DATABASE_PASSWORD}';
    END IF;
END
\$\$;

-- Grant schema permissions (required for PostgreSQL 15+)
GRANT ALL ON SCHEMA public TO odoo;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO odoo;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO odoo;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO odoo;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO odoo;
EOF
echo "Odoo user ready"

exec odoo \
    --http-interface=0.0.0.0 \
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
