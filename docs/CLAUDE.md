# CLAUDE.md

AI assistant guidance for managing Odoo 18 Enterprise deployment on Railway.

---

## Role & Scope

You are assisting with an **Odoo 18 Enterprise** deployment on Railway that follows the **official Odoo Docker pattern**:
- Base: Official `odoo:18.0` Docker image
- Addons: 1337 Enterprise + Community modules (mounted at `/mnt/extra-addons`)
- Database: Railway PostgreSQL service (separate, persistent)
- Storage: Railway volume at `/var/lib/odoo` (filestore, sessions)
- Deployment: Pre-built Docker image (pushed to Docker Hub)

---

## Critical Constraints

### **NEVER Do These:**
1. ❌ Drop or recreate the PostgreSQL database (unless explicitly requested)
2. ❌ Delete or modify the Railway volume `odoo_data`
3. ❌ Change the base image from `odoo:18.0` to custom builds
4. ❌ Commit the `/addons/` folder to git (1.7GB, use Docker image instead)
5. ❌ Expose secrets in git (.env files, passwords, API keys)

### **Always Do These:**
1. ✅ Use official `odoo:18.0` as base image (maintained, optimized by Odoo)
2. ✅ Verify Railway volume is mounted at `/var/lib/odoo` before deployment
3. ✅ Use correct Railway Postgres variable names: `PGHOST`, `PGUSER`, `PGPASSWORD`, `PGPORT`
4. ✅ Build Docker image locally, push to registry (avoid git size limits)
5. ✅ Test changes in development before production deployment

---

## Architecture Overview

### **How It Works:**

```
┌─────────────────────────────────────────┐
│  Railway Deployment                     │
│                                         │
│  ┌───────────────────────────────┐    │
│  │ Docker Container               │    │
│  │                                │    │
│  │  odoo:18.0 (official image)   │    │
│  │  + /mnt/extra-addons (1337)   │◄───┼─── Built locally, pushed to Docker Hub
│  │                                │    │
│  │  Serves on $PORT (8069)       │    │
│  └───────────┬───────────────────┘    │
│              │                          │
│              ├─────────────────────────┼─── Railway Volume: /var/lib/odoo
│              │                          │     (filestore, sessions, attachments)
│              │                          │
│              └─────────────────────────┼─── Railway Postgres Service
│                                         │     (database, permanent data)
└─────────────────────────────────────────┘
```

### **Data Persistence:**
- **Database:** In Railway Postgres (survives container restarts)
- **Filestore:** In Railway volume `/var/lib/odoo` (survives container restarts)
- **Addons:** Baked into Docker image (immutable, update by pushing new image)

---

## Common Tasks

### **1. Deploy New Version / Update Addons**

When Odoo releases a new version or you need to add/remove modules:

```bash
# On local machine (where addons/ folder exists):
cd /Users/r.t.rawlings/odoo-railway

# Update addons if needed
cp -r /path/to/new-odoo-18e/odoo/addons ./addons

# Build new image with version tag
docker build -t roryrawlings/odoo-sparkjar:18.0.2 .

# Push to Docker Hub
docker push roryrawlings/odoo-sparkjar:18.0.2

# Update Railway to use new image (via CLI or UI)
railway up --detach
```

**Database migrations:** Odoo handles automatically on startup.

---

### **2. Debug Database Connection Issues**

**Symptom:** Odoo shows "database connection failed"

**Check:**
1. Railway → Postgres service → Connection tab
2. Verify environment variables in Odoo service:
   ```
   HOST=${{Postgres.PGHOST}}
   USER=${{Postgres.PGUSER}}
   PASSWORD=${{Postgres.PGPASSWORD}}
   PORT=${{Postgres.PGPORT}}
   ```
3. Check Railway logs: `railway logs` for connection errors
4. Verify Postgres service is running and healthy
5. Test connection from Odoo container: `psql -h $HOST -U $USER -d postgres`

**Common mistake:** Using `POSTGRES_USER` instead of `PGUSER` (wrong variable name).

---

### **3. Debug Missing Enterprise Features**

**Symptom:** Enterprise modules not showing in Apps menu

**Check:**
1. Verify addons are in the Docker image:
   ```bash
   docker run --rm roryrawlings/odoo-sparkjar:18.0 ls /mnt/extra-addons | grep web_enterprise
   ```
   Should show: `web_enterprise`, `account_accountant`, `helpdesk`, etc.

2. Check Odoo logs for addons path errors
3. Verify Enterprise registration:
   - Odoo UI → Apps → Look for registration banner
   - Enter subscription code from Odoo.com account
4. Check database: `SELECT name FROM ir_module_module WHERE name LIKE '%enterprise%';`

---

### **4. Debug Volume / Filestore Issues**

**Symptom:** Attachments disappear after restart, or "filestore not found" errors

**Check:**
1. Railway → Service → Volumes → Verify `odoo_data` mounted at `/var/lib/odoo`
2. Check railway.toml has:
   ```toml
   [[deploy.volumeMounts]]
   mountPath = "/var/lib/odoo"
   name = "odoo_data"
   ```
3. Verify volume permissions: Odoo runs as UID 101 (odoo user)
4. Check Odoo logs for filestore path errors

**Fix:** Ensure volume exists and is mounted before first deployment.

---

### **5. Update Environment Variables**

To change Odoo configuration without rebuilding image:

**Railway UI:**
1. Railway → Service → Variables
2. Add/modify variables (e.g., `WORKERS=4`, `LOG_LEVEL=debug`)
3. Restart service for changes to take effect

**Supported variables** (from official odoo:18.0 image):
- `HOST`, `PORT`, `USER`, `PASSWORD` - Database connection
- `WORKERS` - Number of worker processes (performance)
- `WITHOUT_DEMO` - Set to `all` to disable demo data
- `LOG_LEVEL` - `debug`, `info`, `warning`, `error`
- `DB_FILTER` - Database name filtering (security)
- `ADMIN_PASSWD` - Master password for database manager
- `SMTP_*` - SMTP server configuration

**Reference:** https://hub.docker.com/_/odoo

---

### **6. Access Odoo Logs**

**Railway logs:**
```bash
railway logs --tail 100
```

**Or in Railway UI:** Service → Deployments → [Latest] → Logs

**Look for:**
- Database connection errors
- Module loading errors
- Permission errors on /var/lib/odoo
- Addons path warnings

---

### **7. Run Odoo CLI Commands**

To run `odoo-bin` commands (e.g., update modules, shell):

```bash
# Get container ID (if running locally)
docker ps

# Execute command in container
docker exec -it <container-id> odoo --update=module_name --stop-after-init

# Or via Railway (not recommended for production):
railway run odoo --update=all --stop-after-init
```

**Common commands:**
- `--update=module_name` - Update specific module
- `--init=module_name` - Install module
- `--stop-after-init` - Exit after operation (for CI/CD)
- `--shell` - Open Python shell (debugging)

---

### **8. Performance Tuning**

**For production, set these variables:**

```bash
WORKERS=4                    # Based on CPU cores (Railway plan)
MAX_CRON_THREADS=2          # Background job workers
DB_MAXCONN=64               # PostgreSQL connection pool
LIMIT_TIME_CPU=600          # CPU time limit per request (seconds)
LIMIT_TIME_REAL=1200        # Real time limit per request (seconds)
```

**Monitor:** Railway → Metrics → CPU, Memory, Database connections

---

## Deployment Workflow

### **Standard Deployment Process:**

1. **Local Development:**
   - Modify code/addons locally
   - Test with `docker build` and `docker run`

2. **Build Image:**
   ```bash
   docker build -t roryrawlings/odoo-sparkjar:18.0.<version> .
   ```

3. **Push to Registry:**
   ```bash
   docker push roryrawlings/odoo-sparkjar:18.0.<version>
   ```

4. **Deploy to Railway:**
   - Update service to use new image tag
   - Railway pulls and deploys
   - Health check: Verify site is accessible
   - Database migration: Automatic on startup

5. **Verify:**
   - Check Railway logs for errors
   - Test key functionality (login, apps, etc.)
   - Monitor performance metrics

---

## Troubleshooting Decision Tree

```
Issue: Odoo not starting
├─ Check Railway logs
│  ├─ "database connection failed"
│  │  └─ → Check DB env vars (Task #2)
│  ├─ "filestore not found"
│  │  └─ → Check volume mount (Task #4)
│  └─ "module xyz not found"
│     └─ → Check addons in image (Task #3)
│
Issue: Performance problems
├─ Check Railway metrics
│  ├─ High CPU → Increase WORKERS
│  ├─ High Memory → Check for memory leaks, reduce WORKERS
│  └─ Slow DB queries → Optimize database, add indexes
│
Issue: Enterprise features missing
└─ → Check registration (Task #3)
```

---

## Best Practices

### **DO:**
- ✅ Use semantic versioning for Docker images (18.0.1, 18.0.2, etc.)
- ✅ Test in development before production
- ✅ Keep Railway volume backups (snapshots)
- ✅ Monitor Railway logs regularly
- ✅ Use environment variables for configuration (not hardcoded)
- ✅ Document custom modules in readme
- ✅ Keep Odoo and addons updated (security patches)

### **DON'T:**
- ❌ Commit secrets to git
- ❌ Skip database backups before major updates
- ❌ Use `latest` tag (unpredictable, use specific versions)
- ❌ Modify official image internals (use official image as-is)
- ❌ Run database migrations manually (Odoo handles this)

---

## Emergency Procedures

### **Rollback to Previous Version:**

```bash
# Deploy previous working image
railway up --detach roryrawlings/odoo-sparkjar:18.0.<previous-version>
```

### **Database Backup (Before Major Changes):**

```bash
# Via Railway Postgres plugin (recommended)
railway pg:dump > backup-$(date +%Y%m%d).sql

# Or via pg_dump
pg_dump -h $PGHOST -U $PGUSER $PGDATABASE > backup.sql
```

### **Restore Database:**

```bash
# Stop Odoo service first!
railway pg:restore < backup.sql
```

---

## Official Resources

- **Odoo Docker Image:** https://hub.docker.com/_/odoo
- **Odoo 18 Docs:** https://www.odoo.com/documentation/18.0/
- **Railway Docs:** https://docs.railway.app/
- **This Repo README:** See readme.md for full deployment guide

---

## Support Contacts

For issues:
1. Check Railway logs and metrics
2. Consult troubleshooting section above
3. Review official Odoo documentation
4. Check Railway community/support

**Remember:** This uses the official Odoo approach. Most issues are covered in official docs.
