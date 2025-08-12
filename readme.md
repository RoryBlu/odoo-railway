# Odoo on Railway

Deploy Odoo 18.0 ERP/CRM on Railway with PostgreSQL backend.

## Quick Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/odoo)

## Prerequisites

1. **PostgreSQL Database**: Deploy a PostgreSQL service on Railway first
2. **Database User**: Create a dedicated user (NOT 'postgres'):
   ```sql
   CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';
   ```

## Environment Variables

Configure these in Railway's environment variables:

### Required Database Variables
- `HOST` - PostgreSQL host (use `${{Postgres.PGHOST}}`)
- `PORT` - PostgreSQL port (use `${{Postgres.PGPORT}}`)
- `USER` - Database user (e.g., 'odoo')
- `PASSWORD` - Database password

### Optional Variables
- `POSTGRES_DB` - Database name (defaults to 'postgres')
- `ADMIN_PASSWORD` - Odoo admin password (set on first login if not provided)

## Features

- **Odoo 18.0**: Latest stable version with all core modules
- **PostgreSQL Backend**: Reliable database with private networking
- **Persistent Storage**: Volume mount at `/var/lib/odoo` for data persistence
- **Security**: Runs as non-root 'odoo' user (UID 101)
- **Health Checks**: Automatic monitoring and restart on failure

## Post-Deployment

1. Access Odoo at your Railway-provided URL
2. Set admin password on first login
3. Install desired business modules through the Apps interface
4. Configure SMTP settings for email functionality (optional)

## Architecture

This deployment uses the official Odoo Docker image with minimal customization:
- Base image: `odoo:18.0`
- Data persistence: Railway volume at `/var/lib/odoo`
- Networking: Private PostgreSQL connection
- Security: Non-root execution

## Important Notes

- **Never use 'postgres' as database user** - Odoo blocks this for security
- **Save admin credentials** - Set strong password on first login
- **Regular backups recommended** - Use Railway's backup features
- **Module installation** - Some modules may require additional configuration

## Resources

- [Odoo Documentation](https://www.odoo.com/documentation/18.0/)
- [Railway Documentation](https://docs.railway.app/)
- [Odoo GitHub](https://github.com/odoo/odoo)

## Support

For issues specific to this Railway template, please open an issue in this repository.
For Odoo-specific questions, visit the [Odoo Community Forum](https://www.odoo.com/forum/help-1).