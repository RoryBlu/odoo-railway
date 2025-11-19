# SparkJar Odoo 19 Enterprise

**Status:** ✅ Production deployment on Google Cloud Platform

**Instance:** sparkjar-odoo-001 (GCP us-central1-a)

**URLs:**
- https://mgr.sparkjar.agency
- https://mgr.meydomo.com

---

## 📚 Documentation

### Complete Manual (Start Here)

**[docs/SPARKJAR_ODOO_MANUAL.md](docs/SPARKJAR_ODOO_MANUAL.md)** - Comprehensive as-built documentation

This is the **complete reference** for agents operating this Odoo installation, including:
- Architecture overview
- Complete installation history
- All credentials and configuration
- API integration guide
- Database schema
- Operational procedures
- Troubleshooting
- Security hardening

### Historical Documentation

The **[docs/](docs/)** folder also contains setup guides used during deployment:
- GCP instance setup
- SSL configuration
- Odoo installation steps

### AI Assistant Guidance

**[docs/CLAUDE.md](docs/CLAUDE.md)** - Instructions for AI assistants working with this deployment

---

## 🏗️ Architecture

```
GCP Compute Engine (e2-standard-4)
├── Nginx (SSL/TLS reverse proxy)
├── Odoo 19 Enterprise (9 workers)
└── PostgreSQL 16 (sparkjar01 database)

Supabase
└── client_secrets (API credentials for MCP bridge)
```

**Technology:**
- Odoo 19.0 Enterprise (official .deb package)
- Ubuntu 24.04 LTS
- PostgreSQL 16
- Nginx with Let's Encrypt SSL
- Static IP: 34.46.69.152

---

## 🔑 Quick Access

**Admin Login:**
- URL: https://mgr.sparkjar.agency
- Email: talia@sparkjar.agency
- Password: See .env.local

**SSH Access:**
```bash
ssh -i ~/.ssh/sparkjar-odoo-001 r_t_rawlings@34.46.69.152
```

**API Access:**
- Endpoint: https://mgr.sparkjar.agency/xmlrpc/2/
- Database: sparkjar01
- User: admin
- API Key: See .env.local or Supabase client_secrets

---

## 📂 Repository Contents

```
odoo-railway/
├── docs/
│   ├── SPARKJAR_ODOO_MANUAL.md    # Complete reference (start here)
│   ├── CLAUDE.md                   # AI assistant guidance
│   └── [setup guides]              # Historical documentation
├── .env.local                      # All credentials (DO NOT COMMIT)
├── .gitignore                      # Git configuration
├── odoo.conf                       # Reference Odoo config
├── LICENSE                         # Apache 2.0
└── README.md                       # This file
```

**Note:** Railway and Docker files have been removed. This deployment uses the official Odoo .deb package on Ubuntu.

---

## 🚀 Deployment Method

**Native Ubuntu Package (NOT Docker)**

This deployment uses the official Odoo .deb package from odoo.com:
- Installed via `dpkg -i odoo_19.0+e.20251118_all.deb`
- Managed by systemd (`systemctl restart odoo`)
- Configuration in `/etc/odoo/odoo.conf`
- Logs in `/var/log/odoo/odoo-server.log`

See [SPARKJAR_ODOO_MANUAL.md](docs/SPARKJAR_ODOO_MANUAL.md) for complete installation history.

---

## 💰 Cost

**GCP Compute Engine:** ~$115/month (on-demand)

**Components:**
- e2-standard-4 (4 vCPU, 16GB RAM): $98/month
- 100GB SSD boot disk: $17/month
- Static IP: Free when attached

**Commitment Pricing:** ~$84/month with 1-year commitment

---

## 🔒 Security

**Production hardening complete:**
- Master password changed from default
- Database manager disabled (`list_db = False`)
- Odoo restricted to localhost (Nginx reverse proxy only)
- SSL/TLS via Let's Encrypt (auto-renewal configured)
- API key authentication for MCP bridge
- Firewall: Only ports 22, 80, 443 open

See [SPARKJAR_ODOO_MANUAL.md § Security Hardening](docs/SPARKJAR_ODOO_MANUAL.md#security-hardening) for details.

---

## 📞 Support

**For issues:**
1. Check [SPARKJAR_ODOO_MANUAL.md § Troubleshooting](docs/SPARKJAR_ODOO_MANUAL.md#troubleshooting)
2. Review system logs: `/var/log/odoo/odoo-server.log`
3. Consult [Odoo 19 Documentation](https://www.odoo.com/documentation/19.0/)

**Contacts:**
- Enterprise License: talia@sparkjar.agency
- GCP Billing: rory@blucanarycapital.com

---

## 📝 Migration History

**November 15-17, 2025:** Railway deployment attempts (failed)
- Docker build with official odoo:18.0 image
- Nixpacks buildpack (dependency conflicts)
- PORT variable conflicts
- Enterprise addons mounting issues

**November 18-19, 2025:** GCP deployment (successful)
- GCP instance creation and SSH setup
- Odoo 19 Enterprise .deb installation
- SSL certificate configuration
- Production hardening
- Credential storage in Supabase

See [SPARKJAR_ODOO_MANUAL.md § Installation History](docs/SPARKJAR_ODOO_MANUAL.md#installation-history) for complete timeline.

---

Last Updated: November 19, 2025
