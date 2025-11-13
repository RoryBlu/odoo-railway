FROM odoo:18.0

# The official Odoo image already includes:
# - Proper entrypoint script that handles database connections
# - gosu for privilege dropping
# - All necessary dependencies
# - Correct file permissions

# Create a custom entrypoint wrapper to fix volume permissions at runtime
USER root

# Create entrypoint wrapper script
RUN echo '#!/bin/bash\n\
set -e\n\
# Fix permissions on volume mount (Railway mounts volumes after build)\n\
echo "Fixing /var/lib/odoo permissions..."\n\
chown -R odoo:odoo /var/lib/odoo 2>/dev/null || true\n\
chmod -R 755 /var/lib/odoo 2>/dev/null || true\n\
# Call the original Odoo entrypoint\n\
exec /entrypoint.sh "$@"\n\
' > /railway-entrypoint.sh && chmod +x /railway-entrypoint.sh

# Explicitly expose port 8069 for Railway
EXPOSE 8069

# Use our wrapper entrypoint
ENTRYPOINT ["/railway-entrypoint.sh"]
CMD ["odoo"]