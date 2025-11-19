# Odoo Railway → GCP Migration Documentation

This directory contains all documentation for migrating from Railway to Google Cloud Platform.

---

## 🚀 GCP Deployment Guides

### For Rory (Human Operator)
1. **[gcp-credentials-setup-rory.md](gcp-credentials-setup-rory.md)** - Set up GCP account, service accounts, and SSH keys
2. **[gcp-static-ip-setup-rory.md](gcp-static-ip-setup-rory.md)** - Reserve static IP and configure DNS

### For AI Agents
3. **[sparkjar-agent-deployment-instructions.md](sparkjar-agent-deployment-instructions.md)** - Deploy SparkJar Hub on GCP
4. **[odoo-mcp-agent-deployment-instructions.md](odoo-mcp-agent-deployment-instructions.md)** - Deploy Odoo 19 Enterprise + MCP Bridge on GCP

---

## 📋 Project Documentation

- **[CLAUDE.md](CLAUDE.md)** - AI assistant guidance for this repository
- **[readme.md](readme.md)** - Original project README

---

## 📝 Railway Migration Notes (Historical)

- **[railway-automation.md](railway-automation.md)** - Railway deployment automation attempts
- **[railway-log.md](railway-log.md)** - Railway deployment error logs

**Status:** Railway deployment abandoned after 3 days of troubleshooting. Migrating to GCP.

---

## 🎯 Deployment Workflow

### Phase 1: Rory Setup (~1 hour)
1. Follow gcp-credentials-setup-rory.md
2. Follow gcp-static-ip-setup-rory.md
3. Provide credentials to AI agents

### Phase 2: Agent Deployment (~3-4 hours)
1. SparkJar agent deploys Hub
2. Odoo MCP agent deploys Odoo + Bridge

### Phase 3: Integration Testing (~1 hour)
1. Verify services accessible
2. Test integrations
3. Configure workflows

---

## 💰 Cost: ~$115/month (on-demand) or ~$84/month (1-year commitment)

---

## ⚠️ Important: Odoo Source (1.7GB)

**Keep odoo/ directory until GCP deployment is verified**
**Delete after successful testing to save disk space**

---

Last Updated: November 18, 2025
