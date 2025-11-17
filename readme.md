# Odoo 18 on Railway (Community + Enterprise)

This repo builds an Odoo 18 image for Railway using the official `odoo:18.0` Docker image
and layers the Enterprise addons on top.

It is designed to:

- Use an **existing PostgreSQL database** on Railway.
- Use an **existing Railway volume** mounted at `/var/lib/odoo`.
- Run **Odoo 18** with both Community and Enterprise addons.

## 1. Prerequisites

- A running **Postgres** service on Railway (you already have this).
- An existing Odoo database in that Postgres instance (your current CE DB).
- A Railway volume attached to the Odoo service at `/var/lib/odoo`.
- An Odoo Enterprise subscription and the **Odoo 18 Enterprise source** download. 

## 2. Prepare the Enterprise addons

1. Download the Odoo 18 **Enterprise** tarball from your Odoo account. 
2. Extract it locally.
3. From the extracted content, create a folder named `enterprise/` that contains the
   Enterprise addons (standard pattern is CE + separate `enterprise` folder). 
4. Place that `enterprise/` folder in the root of this repo (next to the Dockerfile).

Your tree should look like:

```text
odoo-railway/
  Dockerfile
  railway.toml
  .env.railway
  agents.md
  README.md
  enterprise/
    account_enterprise/
    web_enterprise/
    ...
