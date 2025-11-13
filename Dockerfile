FROM odoo:18.0

# Run as root to fix volume permissions
USER 0

# Copy custom entrypoint script
COPY --chmod=755 entrypoint.sh /app/entrypoint.sh

# Explicitly expose port 8069 for Railway
EXPOSE 8069

WORKDIR /app

ENTRYPOINT ["/bin/sh"]
CMD ["entrypoint.sh"]