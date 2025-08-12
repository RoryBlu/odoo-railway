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
- `railway.toml`: Railway deployment configuration with volume mounting and health checks
- `readme.md`: Contains deployment notes and configuration details
- `.env.railway`: Template for Railway environment variables

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

### SMTP Configuration (Optional)
Standard Odoo SMTP configuration can be passed as command-line arguments or configured through the Odoo interface after deployment.

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
4. Set environment variables in Railway:
   - `HOST=${{Postgres.PGHOST}}`
   - `PORT=${{Postgres.PGPORT}}`
   - `USER=odoo`
   - `PASSWORD=your-secure-password`
5. Volume mount at `/var/lib/odoo` is automatically configured via railway.toml
6. Access Odoo at your Railway-provided URL

## Common Development Tasks

### Building the Docker Image
```bash
docker build -t odoo-railway .
```

### Running Locally
Ensure PostgreSQL is running and accessible, then:
```bash
docker run -p 8069:8069 \
  -e HOST=host.docker.internal \
  -e PORT=5432 \
  -e USER=odoo \
  -e PASSWORD=odoo_password \
  odoo-railway
```

## Important Notes

- Default admin credentials are set on first login - save them securely
- The official Odoo image handles all initialization, database setup, and privilege dropping
- Container runs as 'odoo' user (UID 101) for security
- PostgreSQL 'postgres' user is blocked by Odoo - always create a dedicated database user
- The official entrypoint handles database connection waiting and initialization automatically

## Simplification from Previous Version

This template now uses the official Odoo Docker image's entrypoint instead of a custom one, which:
- Reduces maintenance burden
- Ensures compatibility with Odoo updates
- Uses battle-tested code
- Follows Docker and Odoo best practices