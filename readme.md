# Odoo 18 Enterprise on Railway

Deploy Odoo 18 Enterprise edition on Railway using the **official Docker image** + Enterprise addons.

This follows the [official Odoo Docker deployment pattern](https://hub.docker.com/_/odoo) recommended by Odoo.

---

## 🏗️ Architecture

- **Base:** Official `odoo:18.0` Docker image (optimized, maintained by Odoo)
- **Enterprise Addons:** 1337 modules (Community + Enterprise) from official Odoo 18 package
- **Database:** Railway PostgreSQL service
- **Storage:** Railway volume at `/var/lib/odoo` (persistent filestore)
- **Deployment:** Pre-built Docker image (avoids 1.7GB git push)

---

## 📋 Prerequisites

1. **Odoo 18 Enterprise Package**
   - Download from your Odoo.com account
   - Extract the `odoo/addons` folder (1337 modules, ~1.7GB)
   - Place it as `./addons/` in this repo

2. **Docker Hub Account** (free)
   - Sign up at https://hub.docker.com
   - Create a repository: `yourusername/odoo-sparkjar`

3. **Railway Account**
   - With PostgreSQL service already deployed
   - Volume created and named `odoo_data`

---

## 🚀 Deployment Steps

### Step 1: Prepare the Addons Folder

Extract just the addons from your Odoo 18 Enterprise download:

```bash
# Your Odoo download location
cd /path/to/odoo-18.0+e.20251116

# Copy addons to this repo
cp -r odoo/addons /path/to/odoo-railway/addons
```

Your repo structure should look like:
```
odoo-railway/
├── addons/              # 1337 Odoo modules (1.7GB)
├── Dockerfile
├── railway.toml
├── CLAUDE.md
└── readme.md
```

---

### Step 2: Build Docker Image Locally

Since the `addons/` folder (1.7GB) is too large for GitHub, you build the image locally:

```bash
cd /path/to/odoo-railway

# Build the image (includes addons inside)
docker build -t yourusername/odoo-sparkjar:18.0 .

# Login to Docker Hub
docker login

# Push to Docker Hub (free for public images)
docker push yourusername/odoo-sparkjar:18.0
```

**Note:** The build might take 5-10 minutes due to the 1.7GB addons folder.

---

### Step 3: Configure Railway Environment Variables

In Railway → Your Odoo Service → Variables, add:

**Required Database Variables:**
```bash
HOST=${{Postgres.PGHOST}}
PORT=${{Postgres.PGPORT}}
USER=${{Postgres.PGUSER}}
PASSWORD=${{Postgres.PGPASSWORD}}
```

**Recommended Production Variables:**
```bash
WITHOUT_DEMO=all           # Disable demo data
DB_FILTER=^%d$            # Security: database name filtering
WORKERS=2                  # Performance (adjust based on Railway plan)
LOG_LEVEL=info            # Logging level
```

**Optional SMTP (or configure via Odoo UI later):**
```bash
SMTP_SERVER=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=your-user@domain.com
SMTP_PASSWORD=your-password
EMAIL_FROM=Odoo <noreply@yourdomain.com>
```

---

### Step 4: Deploy to Railway

**Option A: Deploy via Railway CLI**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to your project
railway link

# Set the Docker image
railway up --detach
```

**Option B: Deploy via Railway UI**

1. Go to your Odoo service settings
2. Under "Deploy", select "Docker Image"
3. Enter: `yourusername/odoo-sparkjar:18.0`
4. Railway will pull and deploy the image

---

### Step 5: Verify Volume Mount

Ensure your Railway volume is mounted:

1. Railway → Your Service → Settings → Volumes
2. Verify volume `odoo_data` is mounted at `/var/lib/odoo`

If not, create it:
- Name: `odoo_data`
- Mount path: `/var/lib/odoo`

---

### Step 6: Access Odoo

Once deployed:

1. Get your Railway URL: `https://your-service.railway.app`
2. First visit shows database creation wizard
3. Create your database (or connect to existing)
4. Login with admin credentials

---

## 🔄 Updating Odoo

When you need to update Odoo or add/remove modules:

```bash
# 1. Update addons folder (if new Odoo version)
cp -r /path/to/new-odoo/addons ./addons

# 2. Rebuild image with new tag
docker build -t yourusername/odoo-sparkjar:18.0.1 .
docker push yourusername/odoo-sparkjar:18.0.1

# 3. Update Railway to use new image
railway up --detach
# or update via Railway UI
```

**Note:** Database and filestore persist across updates (in the Railway volume).

---

## 🔐 Enterprise Registration

After first deployment:

1. Login as admin
2. Go to Apps menu
3. Look for Enterprise registration banner
4. Enter your Odoo Enterprise subscription code
5. Click "Register"

This activates all Enterprise features.

---

## 📂 Repository Structure

```
odoo-railway/
├── addons/              # Enterprise + Community addons (gitignored, 1.7GB)
├── Dockerfile           # Uses official odoo:18.0 + addons
├── railway.toml         # Railway deployment config
├── .env.railway         # Environment variable template (gitignored)
├── .gitignore           # Excludes addons and secrets
├── CLAUDE.md            # AI assistant guidance
├── readme.md            # This file
└── railway-automation.md # Automation docs
```

**What's in Git:**
- ✅ Dockerfile, railway.toml, docs
- ❌ addons/ folder (1.7GB, built into Docker image)
- ❌ .env files (secrets)

---

## 🛠️ Troubleshooting

### Database Connection Issues

**Symptom:** Odoo can't connect to PostgreSQL

**Check:**
1. Railway → Postgres → Connection → Verify variables match
2. Ensure `USER`, `PASSWORD`, `HOST`, `PORT` are set correctly
3. Check Railway logs for connection errors

### Missing Enterprise Features

**Symptom:** Enterprise modules not showing

**Check:**
1. Verify addons were copied into Docker image: `docker run --rm yourusername/odoo-sparkjar:18.0 ls /mnt/extra-addons | head`
2. Should show 1337+ modules including `web_enterprise`, `account_accountant`, etc.
3. Check Odoo logs for addons path errors

### Volume Not Persisting

**Symptom:** Attachments/filestore disappear on restart

**Fix:**
1. Railway → Service → Volumes → Ensure `odoo_data` mounted at `/var/lib/odoo`
2. Check railway.toml has `[[deploy.volumeMounts]]` section

### Image Push Too Slow

**Symptom:** `docker push` takes forever (1.7GB upload)

**Tips:**
1. First push is slow (1.7GB), subsequent pushes are fast (Docker layers)
2. Use good internet connection for first push
3. Consider Docker Hub alternatives (GitHub Container Registry, AWS ECR)

---

## 📚 Official Documentation

- [Odoo 18 Docker Image](https://hub.docker.com/_/odoo)
- [Odoo 18 Documentation](https://www.odoo.com/documentation/18.0/)
- [Railway Documentation](https://docs.railway.app/)

---

## 🆘 Support

For issues:
1. Check Railway logs: `railway logs`
2. Check Odoo logs in Railway UI
3. Review CLAUDE.md for AI assistant guidance
4. Consult railway-automation.md for automation patterns

---

**Built with ❤️ using official Odoo Docker image**
