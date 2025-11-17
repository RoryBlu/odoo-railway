#!/bin/bash
set -e

# Image verification logging
echo "========================================"
echo "CUSTOM ENTRYPOINT RUNNING"
echo "Image: roryblu/odoo-sparkjar:18.0"
echo "Build timestamp: $(date -r /docker-entrypoint.sh 2>/dev/null || echo 'unknown')"
echo "========================================"

# Log initial PORT value from Railway
echo "PORT from Railway: '${PORT}'"

# If PORT is empty or unset, don't let it override odoo.conf
# Railway clears PORT, causing "--db_port ''" to override config file
if [ -z "$PORT" ]; then
    echo "PORT is empty - setting to 5432 to prevent Odoo entrypoint error"
    unset PORT
    export PORT=5432
else
    echo "PORT is set: ${PORT}"
fi

echo "Final PORT value: ${PORT}"
echo "========================================"

# Call original Odoo entrypoint
exec /entrypoint.sh "$@"
