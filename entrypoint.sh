#!/bin/sh

set -e

# Set default PORT if not provided by Railway
PORT=${PORT:-8069}

echo "Starting Odoo on port ${PORT}"

# Check if we're using the postgres user (which Odoo blocks for security)
if [ "${ODOO_DATABASE_USER}" = "postgres" ]; then
    echo "ERROR: Using 'postgres' as database user is not allowed by Odoo for security reasons."
    echo "Please create a dedicated database user. For example:"
    echo "  CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';"
    echo ""
    echo "Then update your environment variables:"
    echo "  ODOO_DATABASE_USER=odoo"
    echo "  ODOO_DATABASE_PASSWORD=your-secure-password"
    exit 1
fi

echo "Database user: ${ODOO_DATABASE_USER}"

# Check current user ID
CURRENT_UID=$(id -u)
echo "Running as UID: $CURRENT_UID"

# If not running as odoo user (UID 101), we need to handle permissions
if [ "$CURRENT_UID" != "101" ]; then
    echo "Not running as odoo user (UID 101)"
    
    # If we're root, we can fix permissions
    if [ "$CURRENT_UID" = "0" ]; then
        echo "Running as root, fixing volume permissions..."
        chown -R odoo:odoo /var/lib/odoo || true
        chmod 755 /var/lib/odoo || true
        # Create sessions directory
        mkdir -p /var/lib/odoo/sessions
        chown -R odoo:odoo /var/lib/odoo/sessions
        echo "Volume permissions fixed"
    else
        echo "WARNING: Running as UID $CURRENT_UID (not root, not odoo)"
        echo "Attempting to create writable directories..."
        # Try to create directories anyway
        mkdir -p /var/lib/odoo/sessions 2>/dev/null || true
        mkdir -p /var/lib/odoo/filestore 2>/dev/null || true
        # Check if we can write
        if ! touch /var/lib/odoo/.write_test 2>/dev/null; then
            echo "ERROR: Cannot write to /var/lib/odoo"
            echo "Railway is running container as UID $CURRENT_UID"
            echo "Add RAILWAY_RUN_UID=0 to environment variables to fix"
            exit 1
        fi
        rm -f /var/lib/odoo/.write_test
    fi
fi

# Wait for database with timeout (60 seconds)
echo "Waiting for database at ${ODOO_DATABASE_HOST}:${ODOO_DATABASE_PORT}..."
TIMEOUT=60
COUNTER=0
while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do 
    sleep 1
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "ERROR: Database connection timeout after ${TIMEOUT} seconds"
        exit 1
    fi
    if [ $((COUNTER % 10)) -eq 0 ]; then
        echo "Still waiting for database... (${COUNTER}s)"
    fi
done

echo "Database is now available"

# Check if database is already initialized (look for ir_module_module table)
# Using connection string to avoid password in process list
export PGPASSWORD="${ODOO_DATABASE_PASSWORD}"
DB_INITIALIZED=$(psql -h "${ODOO_DATABASE_HOST}" -p "${ODOO_DATABASE_PORT}" -U "${ODOO_DATABASE_USER}" -d "${ODOO_DATABASE_NAME}" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='ir_module_module'" 2>/dev/null || echo "0")
unset PGPASSWORD

# Build Odoo command
ODOO_CMD="odoo --http-port=${PORT}"
ODOO_CMD="${ODOO_CMD} --without-demo=True"
ODOO_CMD="${ODOO_CMD} --proxy-mode"
ODOO_CMD="${ODOO_CMD} --data-dir=/var/lib/odoo"
ODOO_CMD="${ODOO_CMD} --db_host=${ODOO_DATABASE_HOST}"
ODOO_CMD="${ODOO_CMD} --db_port=${ODOO_DATABASE_PORT}"
ODOO_CMD="${ODOO_CMD} --db_user=${ODOO_DATABASE_USER}"
ODOO_CMD="${ODOO_CMD} --db_password=${ODOO_DATABASE_PASSWORD}"
ODOO_CMD="${ODOO_CMD} --database=${ODOO_DATABASE_NAME}"

# Only init on first run
if [ "$DB_INITIALIZED" != "1" ]; then
    echo "First run detected, initializing database..."
    ODOO_CMD="${ODOO_CMD} --init=base"
fi

# Add SMTP settings only if provided
if [ -n "${ODOO_SMTP_HOST}" ]; then
    ODOO_CMD="${ODOO_CMD} --smtp=${ODOO_SMTP_HOST}"
    [ -n "${ODOO_SMTP_PORT_NUMBER}" ] && ODOO_CMD="${ODOO_CMD} --smtp-port=${ODOO_SMTP_PORT_NUMBER}"
    [ -n "${ODOO_SMTP_USER}" ] && ODOO_CMD="${ODOO_CMD} --smtp-user=${ODOO_SMTP_USER}"
    [ -n "${ODOO_SMTP_PASSWORD}" ] && ODOO_CMD="${ODOO_CMD} --smtp-password=${ODOO_SMTP_PASSWORD}"
fi

[ -n "${ODOO_EMAIL_FROM}" ] && ODOO_CMD="${ODOO_CMD} --email-from=${ODOO_EMAIL_FROM}"

# Handle SIGTERM for graceful shutdown
trap 'echo "Received SIGTERM, shutting down..."; kill -TERM $PID; wait $PID' TERM

echo "Starting Odoo..."

# Handle user switching based on current UID
CURRENT_UID=$(id -u)
if [ "$CURRENT_UID" = "0" ]; then
    # Running as root, can drop privileges
    echo "Dropping privileges to odoo user..."
    exec gosu odoo sh -c "${ODOO_CMD} 2>&1"
elif [ "$CURRENT_UID" = "101" ]; then
    # Already running as odoo user
    echo "Already running as odoo user"
    eval "exec ${ODOO_CMD} 2>&1"
else
    # Running as some other user (like UID 1)
    echo "Running as UID $CURRENT_UID - cannot switch users"
    echo "Container will run with current permissions"
    eval "exec ${ODOO_CMD} 2>&1"
fi