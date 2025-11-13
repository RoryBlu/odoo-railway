# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Odoo deployment template for Railway platform. It provides a containerized setup for running Odoo 18.0 with PostgreSQL database backend using the official Odoo Docker image.

## Architecture

- **Base Image**: Odoo 18.0 official Docker image
- **Database**: PostgreSQL (connected via private network)
- **Entry Point**: Official Odoo entrypoint that handles database connectivity and initialization
- **Configuration**: Environment-variable driven setup using standard Odoo Docker variables

## Key Files

- `Dockerfile`: Minimal extension of odoo:18.0 image to ensure proper volume permissions
- `railway.toml`: Railway deployment configuration with volume mounting, Mailgun SMTP settings, and restart policy
- `.env.railway`: Template for all required Railway environment variables (database + Mailgun)
- `readme.md`: User-facing documentation for deployment
- `setup-db-user.sh`: Helper script to generate SQL commands for creating the Odoo database user

## Environment Variables

The application uses the official Odoo Docker environment variables:

### Database Configuration (Required)
- `HOST`: PostgreSQL host address (e.g., `${{Postgres.PGHOST}}`)
- `PORT`: PostgreSQL port (default: 5432, e.g., `${{Postgres.PGPORT}}`)
- `USER`: Database user (must NOT be 'postgres' - create a dedicated user like 'odoo')
- `PASSWORD`: Database password

### Optional Configuration
- `POSTGRES_DB`: Database name (defaults to 'postgres')
- `ADMIN_PASSWORD`: Odoo admin password (set on first run)

### SMTP Configuration (Mailgun)
The application is configured to use Mailgun for email delivery via SMTP:
- SMTP credentials are set via environment variables in `.env.railway`
- Configuration is passed as command-line arguments in `railway.toml` startCommand
- Domain: mg.meydomo.com
- Mailgun API key is also available for future API integration if needed

Alternative: SMTP can also be configured through the Odoo interface (Settings > Technical > Outgoing Mail Servers)

## Railway Deployment

### Prerequisites
**CRITICAL**: Odoo has security requirements that must be met:
1. **Cannot run as root user** - The container runs as 'odoo' user (UID 101)
2. **Cannot use 'postgres' database user** - You must create a dedicated database user

### Database Setup
Before deploying Odoo, you need to create a non-postgres database user:
1. Option A - Use the helper script: `./setup-db-user.sh` (generates SQL commands for you)
2. Option B - Run SQL directly in Railway PostgreSQL Query tab:
   ```sql
   CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';
   GRANT ALL PRIVILEGES ON DATABASE railway TO odoo;
   ```
3. Use these credentials in your environment variables

### Quick Deploy
1. Deploy PostgreSQL service on Railway first
2. Create the 'odoo' database user (see Database Setup above)
3. Deploy this repository
4. Set environment variables in Railway (see `.env.railway` for all required variables):
   - Database: `HOST`, `PORT`, `USER`, `PASSWORD`
   - Mailgun SMTP: `MAILGUN_SMTP_HOST`, `MAILGUN_SMTP_PORT`, `MAILGUN_SMTP_USER`, `MAILGUN_SMTP_PASSWORD`, `MAILGUN_EMAIL_FROM`
   - Optional: `POSTGRES_DB`, `ADMIN_PASSWORD`, `MAILGUN_API_KEY`, `MAILGUN_DOMAIN`
5. Volume mount at `/var/lib/odoo` is automatically configured via railway.toml
6. Access Odoo at your Railway-provided URL

## Local Development

### Building the Docker Image
```bash
docker build -t odoo-railway .
```

### Running Locally with Docker
Ensure PostgreSQL is running and accessible, then:
```bash
docker run -p 8069:8069 \
  -e HOST=host.docker.internal \
  -e PORT=5432 \
  -e USER=odoo \
  -e PASSWORD=odoo_password \
  odoo-railway
```

Access at: http://localhost:8069

## Important Notes

- **Security**: Container runs as 'odoo' user (UID 101) - never as root
- **Database User**: PostgreSQL 'postgres' user is blocked by Odoo - always create a dedicated database user
- **Admin Credentials**: Set on first login - save them securely
- **Official Entrypoint**: The official Odoo image handles all initialization, database setup, and privilege dropping automatically
- **Volume Persistence**: Data is stored in `/var/lib/odoo` volume (managed by Railway)
- **Email Service**: Configured to use Mailgun SMTP (mg.meydomo.com) via environment variables

## Design Philosophy

This template uses the official Odoo Docker image's entrypoint instead of custom scripts, which:
- Reduces maintenance burden
- Ensures compatibility with Odoo updates
- Uses battle-tested code from the Odoo team
- Follows Docker and Railway best practices