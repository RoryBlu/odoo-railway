#!/bin/bash
set -e

# If PORT is empty or unset, don't let it override odoo.conf
# Railway clears PORT, causing "--db_port ''" to override config file
if [ -z "$PORT" ]; then
    unset PORT
    export PORT=5432
fi

# Call original Odoo entrypoint
exec /entrypoint.sh "$@"
