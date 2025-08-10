FROM odoo:18.0

ARG LOCALE=en_US.UTF-8

ENV LANGUAGE=${LOCALE}
ENV LC_ALL=${LOCALE}
ENV LANG=${LOCALE}

USER 0

RUN apt-get -y update && apt-get install -y --no-install-recommends locales netcat-openbsd \
    && locale-gen ${LOCALE} \
    && mkdir -p /var/lib/odoo \
    && chown -R odoo:odoo /var/lib/odoo \
    && chmod 755 /var/lib/odoo

WORKDIR /app

COPY --chmod=755 entrypoint.sh ./

# Declare volume for persistent data
VOLUME ["/var/lib/odoo"]

# Switch back to odoo user for security
USER odoo

ENTRYPOINT ["/bin/sh"]

CMD ["entrypoint.sh"]