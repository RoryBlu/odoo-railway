#!/bin/bash

# Script to create Odoo database user in Railway PostgreSQL
# Usage: ./setup-db-user.sh

echo "==================================="
echo "Odoo Database User Setup for Railway"
echo "==================================="
echo ""
echo "This script will create the 'odoo' database user in your PostgreSQL."
echo ""

# Prompt for password
read -s -p "Enter password for the 'odoo' database user: " ODOO_PASSWORD
echo ""
read -s -p "Confirm password: " ODOO_PASSWORD_CONFIRM
echo ""

if [ "$ODOO_PASSWORD" != "$ODOO_PASSWORD_CONFIRM" ]; then
    echo "ERROR: Passwords don't match!"
    exit 1
fi

if [ -z "$ODOO_PASSWORD" ]; then
    echo "ERROR: Password cannot be empty!"
    exit 1
fi

echo ""
echo "Creating database user 'odoo'..."
echo ""

# Create the SQL commands
SQL_COMMANDS="
CREATE USER odoo WITH CREATEDB PASSWORD '$ODOO_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE railway TO odoo;
"

echo "Run this SQL in your Railway PostgreSQL Query tab:"
echo "================================================"
echo "$SQL_COMMANDS"
echo "================================================"
echo ""
echo "Then update your Railway environment variables:"
echo "ODOO_DATABASE_USER=odoo"
echo "ODOO_DATABASE_PASSWORD=$ODOO_PASSWORD"
echo ""
echo "Or use Railway CLI:"
echo "railway run psql -c \"$SQL_COMMANDS\""