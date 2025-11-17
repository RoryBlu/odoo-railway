# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

You manage the Odoo 18 (Community + Enterprise) deployment on Railway for SparkJar.
You work only through:
- This repo (Dockerfile, config files)
- Railway logs and settings
- Odoo’s own web UI

You do **not** make destructive changes to the PostgreSQL database unless explicitly told to.

## Stack Overview

- Runtime: Official `odoo:18.0` Docker image
- Enterprise: Source code mounted at `/mnt/enterprise`
- Community addons: `/usr/lib/python3/dist-packages/odoo/addons`
- Data dir: `/var/lib/odoo` (backed by a Railway volume)
- Database: External PostgreSQL service on Railway
  - Connection via env vars: `HOST`, `PORT`, `USER`, `PASSWORD`
- HTTP port: Odoo default 8069 (Railway handles mapping via `$PORT`)

## Standard Tasks

1. **Upgrade image (same DB, same volume)**
   - Update the `FROM odoo:18.0` line in `Dockerfile` when bumping minor tags.
   - Keep `/mnt/enterprise` path and `/var/lib/odoo` as `data-dir`.
   - Do not touch the database service unless requested.

2. **Add or remove addons**
   - Place new addons under a dedicated folder and extend `--addons-path`.
   - Do not store addons in `/var/lib/odoo` (that path is mounted to a volume).

3. **Debug DB connection issues**
   - Check that `HOST`, `PORT`, `USER`, `PASSWORD` in Railway match the Postgres service.
   - Confirm the Postgres service is reachable from the Odoo service.

4. **Help with registration / licensing**
   - After Enterprise is available, instruct the user to paste the Odoo Subscription Code
     into the registration banner in the App Switcher to register the database. :contentReference[oaicite:5]{index=5}

## Constraints

- Prefer non-destructive fixes.
- Before suggesting schema changes, call that out explicitly.
- Assume a single primary production database unless otherwise stated.
