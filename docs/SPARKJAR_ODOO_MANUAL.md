# SparkJar Odoo 19 Enterprise Manual

**As-Built Documentation for GCP Deployment**
**Last Updated:** November 19, 2025
**Instance:** sparkjar-odoo-001 (GCP)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Installation History](#installation-history)
4. [Access & Credentials](#access--credentials)
5. [Configuration Details](#configuration-details)
6. [API Integration](#api-integration)
7. [Database Schema](#database-schema)
8. [Operational Procedures](#operational-procedures)
9. [Troubleshooting](#troubleshooting)
10. [Security Hardening](#security-hardening)

---

## Overview

### What This Is

This is a **headless Odoo 19 Enterprise** installation running on Google Cloud Platform. The system serves as the backend CRM/business management platform for SparkJar and all client agencies, accessed exclusively via API through the SparkJar-Odoo-MCP bridge.

### Key Details

- **Platform:** GCP Compute Engine (e2-standard-4)
- **OS:** Ubuntu 24.04 LTS
- **Odoo Version:** 19.0 Enterprise (official .deb package from odoo.com)
- **Database:** sparkjar01 (PostgreSQL 16, local)
- **Primary Domain:** https://mgr.sparkjar.agency
- **Secondary Domain:** https://mgr.meydomo.com
- **Static IP:** 34.46.69.152
- **Installation Method:** Native Ubuntu package (NOT Docker)

### Why GCP Instead of Railway

After 3 days of failed attempts on Railway (dependency conflicts, buildpack issues, PORT variable conflicts), the decision was made to migrate to GCP using the official Odoo .deb package. This provides:
- Official Odoo support and updates via apt
- Native Ubuntu service management
- Predictable deployment process
- Better performance (dedicated resources)
- Enterprise-grade stability

---

## Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  GCP Compute Engine (sparkjar-odoo-001)                     │
│  Region: us-central1-a                                       │
│  Machine: e2-standard-4 (4 vCPU, 16GB RAM)                  │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Nginx Reverse Proxy (Port 443/80)                  │    │
│  │ - SSL/TLS via Let's Encrypt                        │    │
│  │ - mgr.sparkjar.agency                               │    │
│  │ - mgr.meydomo.com                                   │    │
│  │ - Auto-renewal configured                           │    │
│  └──────────────┬─────────────────────────────────────┘    │
│                 │                                            │
│  ┌──────────────▼─────────────────────────────────────┐    │
│  │ Odoo 19 Enterprise (Port 8069, localhost only)     │    │
│  │ - 9 workers (4 vCPU * 2 + 1)                       │    │
│  │ - Proxy mode enabled                                │    │
│  │ - Database manager disabled                         │    │
│  │ - Filestore: /var/lib/odoo                         │    │
│  │ - Logs: /var/log/odoo/odoo-server.log             │    │
│  └──────────────┬─────────────────────────────────────┘    │
│                 │                                            │
│  ┌──────────────▼─────────────────────────────────────┐    │
│  │ PostgreSQL 16 (Port 5432, localhost)               │    │
│  │ - Database: sparkjar01                              │    │
│  │ - User: odoo                                        │    │
│  │ - Max connections: 64                               │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘

                            │
                            │ API Calls via MCP Bridge
                            ▼

┌─────────────────────────────────────────────────────────────┐
│  Supabase Database (Client Secrets)                         │
│  - client_secrets table                                      │
│  - Stores Odoo API credentials for each client              │
│  - sparkjar: mgr.sparkjar.agency                            │
│  - meydomo: mgr.meydomo.com                                 │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Web Server:** Nginx 1.24.0
- **Application:** Odoo 19.0 Enterprise
- **Database:** PostgreSQL 16
- **SSL:** Let's Encrypt (certbot)
- **OS:** Ubuntu 24.04 LTS
- **Python:** 3.12 (via Odoo package)

### Network Configuration

- **Static IP:** 34.46.69.152 (reserved: sparkjar-odoo-001-ip)
- **Firewall Rules:**
  - allow-http: tcp:80
  - allow-https: tcp:443
  - allow-ssh: tcp:22
- **DNS Records:**
  - mgr.sparkjar.agency → 34.46.69.152
  - mgr.meydomo.com → 34.46.69.152

---

## Installation History

See the complete installation steps in this section.

**Day 4: GCP Migration (November 18-19, 2025)**

Successfully deployed Odoo 19 Enterprise on GCP using native Ubuntu package installation. All services configured, SSL certificates obtained, and production hardening completed.

**Key accomplishments:**
- GCP instance created and configured
- Odoo 19 Enterprise installed via official .deb package
- SSL certificates obtained for both domains
- Production configuration applied
- Security hardened (master password, database manager disabled)
- Credentials stored in Supabase client_secrets table
- Comprehensive documentation created

---

## Access & Credentials

### Complete Environment Configuration

All credentials are stored in `/Users/r.t.rawlings/odoo-railway/.env.local` on the local development machine. This file contains:

- GCP project and instance details
- SSH keys and access configuration
- Odoo master password (production)
- Odoo admin credentials
- Odoo API key
- PostgreSQL credentials
- Supabase database connection details
- SSL certificate information

**IMPORTANT:** Never commit .env.local to git. It's in .gitignore.

### SSH Access

```bash
# Connect to GCP instance
ssh -i ~/.ssh/sparkjar-odoo-001 r_t_rawlings@34.46.69.152
```

### Odoo Web UI Access

**URLs:**
- https://mgr.sparkjar.agency
- https://mgr.meydomo.com
- https://34.46.69.152

**Admin Credentials:**
- Email: talia@sparkjar.agency
- Password: See .env.local (ODOO_ADMIN_PASSWORD)

### API Access

**Endpoint:** https://mgr.sparkjar.agency/xmlrpc/2/
**Database:** sparkjar01
**User:** admin
**API Key:** See .env.local (ODOO_API_KEY) or Supabase client_secrets table

---

## Configuration Details

### Odoo Configuration File

**Location:** `/etc/odoo/odoo.conf` on GCP instance

**Key settings:**
- Workers: 9 (optimized for 4 vCPU)
- Memory limits: 2.5GB soft, 2.7GB hard
- Database manager: DISABLED (list_db = False)
- Proxy mode: Enabled
- HTTP interface: 127.0.0.1 (localhost only)

### System Services

**Odoo Service:**
```bash
systemctl status odoo
systemctl restart odoo
journalctl -u odoo -f
```

**Nginx Service:**
```bash
systemctl status nginx
nginx -t
systemctl reload nginx
```

**PostgreSQL Service:**
```bash
systemctl status postgresql
```

**SSL Auto-Renewal:**
```bash
systemctl status certbot.timer
certbot renew --dry-run
```

---

## API Integration

### Odoo XML-RPC API

**Endpoint:** https://mgr.sparkjar.agency/xmlrpc/2/

**Authentication with API Key (Recommended):**
```python
import xmlrpc.client

url = "https://mgr.sparkjar.agency"
db = "sparkjar01"
username = "admin"
api_key = "61d0ebeb6cbe66f96f1e40b8600499b8c935a46c"

common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(url))
uid = common.authenticate(db, username, api_key, {})

models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))

# Example: Read partner data
partners = models.execute_kw(db, uid, api_key,
    'res.partner', 'search_read',
    [[['is_company', '=', True]]],
    {'fields': ['name', 'country_id', 'comment'], 'limit': 5})
```

### Key Odoo Models

- `res.partner` - Contacts/Companies
- `crm.lead` - CRM Leads/Opportunities
- `sale.order` - Sales Orders
- `account.move` - Invoices/Bills
- `project.project` - Projects
- `project.task` - Tasks
- `helpdesk.ticket` - Support Tickets

---

## Database Schema

### Supabase: client_secrets Table

**Purpose:** Store Odoo API credentials for each client

**Pattern for Odoo Credentials:**
```json
{
  "secret_key": "odoo.api_credentials",
  "secrets_metadata": {
    "db": "sparkjar01",
    "url": "https://mgr.sparkjar.agency",
    "user": "admin",
    "api_key": "61d0ebeb6cbe66f96f1e40b8600499b8c935a46c"
  }
}
```

**Current Records:**

| Client | URL | Database |
|--------|-----|----------|
| SparkJar LLC | https://mgr.sparkjar.agency | sparkjar01 |
| Meydomo.com | https://mgr.meydomo.com | sparkjar01 |

### PostgreSQL: sparkjar01 Database

**Important Tables:**
- `res_partner` - Contacts/Companies
- `res_users` - Users
- `crm_lead` - CRM Leads
- `sale_order` - Sales Orders
- `project_task` - Tasks
- `helpdesk_ticket` - Support Tickets

---

## Operational Procedures

### Daily Operations

**Check System Health:**
```bash
# SSH to instance
ssh -i ~/.ssh/sparkjar-odoo-001 r_t_rawlings@34.46.69.152

# Check services
systemctl status odoo
systemctl status nginx
systemctl status postgresql

# View Odoo logs
tail -f /var/log/odoo/odoo-server.log

# Check disk usage
df -h

# Check memory
free -h
```

### Backup Procedures

**Database Backup:**
```bash
# On GCP instance
sudo -u postgres pg_dump sparkjar01 > /home/r_t_rawlings/backups/sparkjar01-$(date +%Y%m%d-%H%M%S).sql
gzip /home/r_t_rawlings/backups/sparkjar01-*.sql
```

**Filestore Backup:**
```bash
# Backup attachments and files
sudo tar -czf /home/r_t_rawlings/backups/filestore-$(date +%Y%m%d-%H%M%S).tar.gz /var/lib/odoo
```

### SSL Certificate Renewal

**Automatic:** Configured via certbot.timer (runs twice daily)

**Manual:**
```bash
sudo certbot renew --force-renewal
sudo systemctl restart nginx
```

**Check expiry:**
```bash
sudo certbot certificates
```

### Adding New Client Domains

1. Update DNS: A record → 34.46.69.152
2. Update SSL: `sudo certbot --nginx -d mgr.sparkjar.agency -d mgr.meydomo.com -d mgr.newclient.com`
3. Add to Supabase client_secrets table

---

## Troubleshooting

### Odoo Won't Start

```bash
# Check service status
systemctl status odoo
journalctl -u odoo -n 50

# Check port conflicts
sudo lsof -i :8069

# Fix permissions
sudo chown -R odoo:odoo /var/lib/odoo
sudo chown -R odoo:odoo /var/log/odoo
```

### 502 Bad Gateway

```bash
# Is Odoo running?
systemctl status odoo

# Can Nginx reach Odoo?
curl http://localhost:8069

# Restart services
systemctl restart odoo
systemctl restart nginx
```

### SSL Certificate Issues

```bash
# Check expiry
sudo certbot certificates

# Renew certificate
sudo certbot renew --force-renewal
systemctl restart nginx
```

### Database Performance

```sql
-- Find slow queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - pg_stat_activity.query_start > interval '5 seconds';

-- Vacuum database
sudo -u postgres vacuumdb -z -d sparkjar01
```

---

## Security Hardening

### Implemented Security Measures

1. **Master Password Changed** - 48-character random string
2. **Database Manager Disabled** - `list_db = False`
3. **HTTP Interface Restricted** - localhost only
4. **Proxy Mode Enabled** - Trusts X-Forwarded-For headers
5. **SSL/TLS Enforced** - Let's Encrypt with auto-renewal
6. **Firewall Configured** - Only ports 22, 80, 443 open
7. **API Key Authentication** - Required for MCP bridge

### Credential Rotation

**Rotate master password:**
```bash
# Generate new password
openssl rand -base64 48

# Update /etc/odoo/odoo.conf
# Restart Odoo
systemctl restart odoo
```

**Rotate API keys:**
1. Odoo UI → Settings → Users → admin → API Keys
2. Delete old key, create new key
3. Update client_secrets in Supabase

---

## Quick Reference

### Essential Commands

```bash
# SSH to server
ssh -i ~/.ssh/sparkjar-odoo-001 r_t_rawlings@34.46.69.152

# Check Odoo status
systemctl status odoo

# Restart Odoo
sudo systemctl restart odoo

# View logs
tail -f /var/log/odoo/odoo-server.log

# Backup database
sudo -u postgres pg_dump sparkjar01 | gzip > backup-$(date +%Y%m%d).sql.gz

# Check SSL expiry
sudo certbot certificates
```

### Important URLs

- **Primary:** https://mgr.sparkjar.agency
- **Secondary:** https://mgr.meydomo.com
- **API:** https://mgr.sparkjar.agency/xmlrpc/2/
- **GCP Console:** https://console.cloud.google.com/compute/instances?project=sparkjar-cos

---

**Document End**

*This manual was created on November 19, 2025 as a complete as-built record of the SparkJar Odoo 19 Enterprise deployment on GCP.*
