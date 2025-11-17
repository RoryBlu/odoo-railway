# Dockerfile
# Odoo 18 Community + Enterprise addons on Railway

FROM odoo:18.0

# Build steps run as root
USER root

# Directory for Enterprise addons
RUN mkdir -p /mnt/enterprise && chown -R odoo:odoo /mnt/enterprise

# IMPORTANT:
# You must place the extracted Odoo 18 Enterprise "enterprise" folder
# at the root of this repo before building.
COPY enterprise /mnt/enterprise

# Make sure permissions are correct
RUN chown -R odoo:odoo /mnt/enterprise

# Switch back to the odoo user for runtime
USER odoo

# Default working directory (also where the Railway volume is mounted)
WORKDIR /var/lib/odoo

# Run Odoo:
# - keep data_dir at /var/lib/odoo (matches your Railway volume)
# - add /mnt/enterprise to addons_path
CMD [
  "odoo",
  "--addons-path=/usr/lib/python3/dist-packages/odoo/addons,/mnt/enterprise",
  "--data-dir=/var/lib/odoo"
]
