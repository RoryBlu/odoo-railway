FROM odoo:18.0

# The official Odoo image already includes:
# - Proper entrypoint script that handles database connections
# - gosu for privilege dropping
# - All necessary dependencies
# - Correct file permissions

# We only need to ensure Railway can write to the data directory
USER root
RUN mkdir -p /var/lib/odoo && \
    chown -R odoo:odoo /var/lib/odoo && \
    chmod 755 /var/lib/odoo

# Switch back to odoo user
USER odoo

# Explicitly expose port 8069 for Railway
EXPOSE 8069

# The official image's entrypoint handles everything