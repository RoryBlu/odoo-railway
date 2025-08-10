FROM odoo:18.0

ARG LOCALE=en_US.UTF-8

ENV LANGUAGE=${LOCALE}
ENV LC_ALL=${LOCALE}
ENV LANG=${LOCALE}

USER 0

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    locales netcat-openbsd postgresql-client \
    && locale-gen ${LOCALE} \
    && mkdir -p /var/lib/odoo \
    && chown -R odoo:odoo /var/lib/odoo \
    && chmod 755 /var/lib/odoo

# Create app directory and set permissions while still root
RUN mkdir -p /app && chown -R odoo:odoo /app

WORKDIR /app

# Copy entrypoint and fix permissions
COPY --chown=odoo:odoo --chmod=755 entrypoint.sh /app/

# Note: Not declaring VOLUME to avoid conflicts with Railway's volume mounting
# Railway will handle volume mounting via railway.toml

# Switch back to odoo user for security
USER odoo

ENTRYPOINT ["/bin/sh"]

CMD ["entrypoint.sh"]