# Dockerfile
# Odoo 18 Enterprise on Railway using official image + Enterprise addons
# Following official Odoo Docker deployment pattern

FROM odoo:18.0

USER root

# Copy Enterprise + Community addons (1337 modules total)
# This includes both CE and EE addons from the official Odoo 18 Enterprise package
COPY addons /mnt/extra-addons

# Set proper ownership for the odoo user
RUN chown -R odoo:odoo /mnt/extra-addons

# Switch back to odoo user for security
USER odoo

# The official odoo:18.0 image already provides:
# - Odoo framework and core
# - All system dependencies
# - Proper entrypoint script
# - Configuration handling via environment variables
# - Volume support for /var/lib/odoo

# Environment variables (can be overridden by Railway):
# - DB configuration: Use Railway's Postgres service variables
# - PORT: Railway sets this automatically
# - Data directory: /var/lib/odoo (mount Railway volume here)

# The official entrypoint handles:
# - Database connection (via env vars: HOST, PORT, USER, PASSWORD, etc.)
# - Addons path configuration (--addons-path)
# - Port configuration (defaults to 8069)
# - All standard Odoo CLI arguments

# No custom entrypoint needed - the official image handles everything!
