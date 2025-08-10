# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Odoo deployment template for Railway platform. It provides a containerized setup for running Odoo 18.0 with PostgreSQL database backend.

## Architecture

- **Base Image**: Odoo 18.0 official Docker image
- **Database**: PostgreSQL (connected via private network)
- **Entry Point**: Custom shell script that waits for database availability before starting Odoo
- **Configuration**: Environment-variable driven setup for database, SMTP, and runtime parameters

## Key Files

- `Dockerfile`: Extends odoo:18.0 image with locales and netcat for health checking
- `entrypoint.sh`: Startup script that ensures database connectivity before launching Odoo
- `railway.toml`: Railway deployment configuration with automatic PostgreSQL variable mapping
- `readme.md`: Contains deployment notes and configuration details

## Environment Variables

The application expects these environment variables at runtime:

### Database Configuration
- `ODOO_DATABASE_HOST`: PostgreSQL host address
- `ODOO_DATABASE_PORT`: PostgreSQL port (typically 5432)
- `ODOO_DATABASE_USER`: Database user
- `ODOO_DATABASE_PASSWORD`: Database password
- `ODOO_DATABASE_NAME`: Database name for Odoo

### SMTP Configuration
- `ODOO_SMTP_HOST`: Mail server host
- `ODOO_SMTP_PORT_NUMBER`: Mail server port
- `ODOO_SMTP_USER`: SMTP authentication user
- `ODOO_SMTP_PASSWORD`: SMTP authentication password
- `ODOO_EMAIL_FROM`: Default sender email address

### Runtime
- `PORT`: HTTP port for Odoo service
- `LOCALE`: System locale (default: en_US.UTF-8)

## Railway Deployment

### Prerequisites
**CRITICAL**: Odoo has security requirements that must be met:
1. **Cannot run as root user** - The container runs as 'odoo' user (UID 101)
2. **Cannot use 'postgres' database user** - You must create a dedicated database user

### Database Setup
Before deploying Odoo, you need to create a non-postgres database user:
1. Connect to your PostgreSQL instance
2. Create a dedicated user:
   ```sql
   CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';
   ```
3. Use these credentials in your environment variables

### Quick Deploy
1. Deploy PostgreSQL service on Railway first
2. Create the 'odoo' database user (see Database Setup above)
3. Deploy this repository
4. Set environment variables (see .env.railway for template)
5. Add volume mount at `/var/lib/odoo` for persistent storage
6. Configure SMTP settings in Railway dashboard (optional)
7. Access Odoo at your Railway-provided URL

The `railway.toml` file automatically configures:
- PostgreSQL connection using Railway's service variables
- Dynamic port assignment
- Health checks and restart policies
- SMTP placeholders for easy configuration

### Manual Environment Variables (if not using railway.toml)
If deploying without railway.toml, manually set these in Railway:
- `ODOO_DATABASE_HOST=${{Postgres.PGHOST}}`
- `ODOO_DATABASE_PORT=${{Postgres.PGPORT}}`
- `ODOO_DATABASE_USER=${{Postgres.PGUSER}}`
- `ODOO_DATABASE_PASSWORD=${{Postgres.PGPASSWORD}}`
- `ODOO_DATABASE_NAME=${{Postgres.PGDATABASE}}`

## Common Development Tasks

### Building the Docker Image
```bash
docker build -t odoo-railway .
```

### Running Locally
Ensure PostgreSQL is running and accessible, then:
```bash
docker run -p 8069:8069 \
  -e ODOO_DATABASE_HOST=host.docker.internal \
  -e ODOO_DATABASE_PORT=5432 \
  -e ODOO_DATABASE_USER=odoo \
  -e ODOO_DATABASE_PASSWORD=odoo_password \
  -e ODOO_DATABASE_NAME=odoo \
  -e PORT=8069 \
  odoo-railway
```

## Important Notes

- Default admin credentials are `admin`/`admin` - change immediately after first login
- The application runs with `--proxy-mode` enabled for reverse proxy compatibility
- All modules are initialized on first run (`--init=all`)
- Demo data is disabled (`--without-demo=True`)
- Database connection uses private networking by default with no external exposure
- Container runs as 'odoo' user (UID 101) for security - never as root
- PostgreSQL 'postgres' user is blocked by Odoo - always create a dedicated database user