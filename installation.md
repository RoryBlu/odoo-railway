# Odoo on Railway - Complete Installation Guide

This guide walks you through deploying Odoo 18.0 on Railway from scratch, including PostgreSQL setup and configuration.

## Prerequisites

- Railway account (sign up at https://railway.app)
- GitHub account (to connect this repository)
- Basic familiarity with environment variables

---

## Step 1: Deploy PostgreSQL Database

### 1.1 Create New Project
1. Log into Railway (https://railway.app)
2. Click **"New Project"**
3. Select **"Deploy PostgreSQL"** from the template options
4. Railway will automatically provision a PostgreSQL 16 instance
5. Wait for deployment to complete (usually 30-60 seconds)

### 1.2 Note Your Database Credentials
Once deployed, click on the PostgreSQL service and go to the **"Variables"** tab. You'll need these values:
- `PGHOST` - Database host address
- `PGPORT` - Database port (usually 5432)
- `PGDATABASE` - Database name (usually "railway")
- `PGUSER` - Default user (usually "postgres")
- `PGPASSWORD` - Database password

---

## Step 2: Create Odoo Database User

**CRITICAL**: Odoo cannot use the 'postgres' user for security reasons. You must create a dedicated user.

### 2.1 Open PostgreSQL Query Tab
1. In Railway, click on your PostgreSQL service
2. Click the **"Query"** tab
3. This opens a SQL console

### 2.2 Create the Odoo User
Run this SQL command (replace `your-secure-password` with a strong password):

```sql
CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE railway TO odoo;
```

**Save this password securely** - you'll need it for the Odoo configuration.

### Alternative: Use Helper Script
You can also run the helper script locally to generate the SQL:
```bash
./setup-db-user.sh
```

---

## Step 3: Deploy Odoo Service

### 3.1 Add Odoo to Your Project
1. In your Railway project, click **"New"** → **"GitHub Repo"**
2. Connect your GitHub account if not already connected
3. Select this repository: `odoo-railway`
4. Railway will automatically detect the Dockerfile and start building

### 3.2 Wait for Initial Build
- First build takes 3-5 minutes (downloading Odoo base image)
- You'll see build logs in the deployment view
- Don't configure environment variables yet - let it fail first (it will fail without database connection)

---

## Step 4: Configure Environment Variables

### 4.1 Open Odoo Service Variables
1. Click on your Odoo service in Railway
2. Click the **"Variables"** tab
3. Click **"New Variable"**

### 4.2 Add Required Database Variables

Add these variables one by one (click "+ New Variable" for each):

**Database Connection:**
```
HOST = ${{Postgres.PGHOST}}
PORT = ${{Postgres.PGPORT}}
USER = odoo
PASSWORD = your-secure-password-from-step-2
```

**Database Name (Optional):**
```
POSTGRES_DB = railway
```

### 4.3 Add Mailgun SMTP Variables

**Mailgun SMTP Configuration:**
```
MAILGUN_SMTP_HOST = smtp.mailgun.org
MAILGUN_SMTP_PORT = 587
MAILGUN_SMTP_USER = your-mailgun-smtp-username
MAILGUN_SMTP_PASSWORD = your-mailgun-smtp-password
MAILGUN_EMAIL_FROM = noreply@yourdomain.com
```

**Mailgun API (Optional - for future use):**
```
MAILGUN_API_KEY = your-mailgun-api-key
MAILGUN_DOMAIN = yourdomain.com
```

### 4.4 Set Odoo Admin Password (Optional but Recommended)

```
ADMIN_PASSWORD = your-strong-admin-password-here
```

If you don't set this, you'll be prompted to create one on first login.

### 4.5 Using Railway's Variable References

Railway's `${{ServiceName.VARIABLE}}` syntax automatically pulls values from other services:
- `${{Postgres.PGHOST}}` automatically gets the PostgreSQL host
- `${{Postgres.PGPORT}}` automatically gets the PostgreSQL port
- This keeps your services connected even if Railway changes internal addresses

---

## Step 5: Deploy and Verify

### 5.1 Trigger Deployment
1. After adding all variables, Railway will automatically redeploy
2. Watch the deployment logs for any errors
3. Look for: `"HTTP service (werkzeug) running on http://0.0.0.0:8069"`
4. Deployment takes 1-2 minutes

### 5.2 Generate Public URL
1. Click on your Odoo service
2. Go to **"Settings"** tab
3. Scroll to **"Networking"** section
4. Click **"Generate Domain"**
5. Railway will assign you a URL like: `odoo-production-xxxx.up.railway.app`

### 5.3 Access Odoo
1. Open your Railway-provided URL in a browser
2. You should see the Odoo database manager screen
3. If you see an error, check the deployment logs

---

## Step 6: Initialize Odoo Database

### 6.1 First Time Setup
When you first access Odoo, you'll see the database manager:

1. **Master Password**: Enter the `ADMIN_PASSWORD` you set (or create a new one if you didn't set it)
2. **Database Name**: Enter a name (e.g., `odoo_production`)
3. **Email**: Your admin email address
4. **Password**: Your Odoo user password
5. **Phone**: Optional
6. **Language**: Select your language
7. **Country**: Select your country
8. **Demo Data**: Choose "Load demonstration data" only if you want sample data

Click **"Create Database"** - this takes 2-3 minutes.

### 6.2 First Login
After initialization:
1. You'll be automatically logged in as the admin user
2. You'll see the Odoo Apps dashboard
3. Install the apps/modules you need for your business

---

## Step 7: Verify Email Configuration

### 7.1 Test Email Sending
1. Go to **Settings** → **Technical** → **Outgoing Mail Servers**
2. You should see a server configured with Mailgun settings
3. Click **"Test Connection"** to verify
4. If successful, your email is working!

### 7.2 Troubleshooting Email
If email isn't working:
- Check your Mailgun dashboard at https://app.mailgun.com
- Verify your domain (mg.meydomo.com) is active
- Check the deployment logs for SMTP errors
- Verify all SMTP environment variables are set correctly

---

## Step 8: Configure Volume Persistence

Railway automatically handles this via `railway.toml`, but verify:

1. Click on your Odoo service
2. Go to **"Volumes"** tab
3. You should see a volume mounted at `/var/lib/odoo`
4. This volume stores:
   - Uploaded files and attachments
   - Session data
   - Filestore

**This volume persists across deployments** - your data is safe during updates.

---

## Post-Installation Checklist

- [ ] PostgreSQL is running (green status)
- [ ] Odoo is running (green status)
- [ ] Database connection is working
- [ ] Public URL is generated and accessible
- [ ] Database is initialized
- [ ] Admin login works
- [ ] Email test passes
- [ ] Volume is mounted

---

## Common Issues and Solutions

### Issue: "Database Creation Error"
**Cause**: Odoo user doesn't have CREATEDB permission
**Solution**: Re-run the SQL from Step 2.2 in PostgreSQL Query tab

### Issue: "Connection Refused" or "Can't connect to database"
**Cause**: Wrong database credentials or PostgreSQL not running
**Solution**:
- Verify PostgreSQL service is running (green status)
- Double-check `HOST`, `PORT`, `USER`, `PASSWORD` variables
- Ensure you're using `odoo` user, not `postgres`

### Issue: "Permission Denied" on startup
**Cause**: Volume permissions issue
**Solution**: This shouldn't happen with the current Dockerfile, but if it does:
- Check deployment logs
- Verify `runAsUser = 101` is set in railway.toml

### Issue: "502 Bad Gateway" or "Application Failed to Respond"
**Cause**: Odoo hasn't started yet or crashed during startup
**Solution**:
- Check deployment logs for errors
- Wait 2-3 minutes for full startup
- If it persists, check database connection

### Issue: Email Sending Fails
**Cause**: Mailgun credentials incorrect or domain not verified
**Solution**:
- Verify Mailgun domain at https://app.mailgun.com
- Check SMTP credentials are correct
- Test with Mailgun's web interface first

---

## Maintenance and Updates

### Viewing Logs
1. Click on Odoo service
2. Go to **"Deployments"** tab
3. Click on the latest deployment
4. View real-time logs

### Restarting the Service
1. Click on Odoo service
2. Go to **"Settings"** tab
3. Click **"Restart"** button

### Updating Odoo
This template uses `odoo:18.0` which tracks the latest 18.0 release.

To update:
1. Go to your Odoo service
2. Click **"Deployments"** tab
3. Click **"Redeploy"** on the latest deployment
4. Railway will pull the latest Odoo 18.0 image

### Database Backups
**IMPORTANT**: Railway doesn't automatically backup your PostgreSQL data.

Recommended backup strategy:
1. Use Odoo's built-in backup: **Settings** → **Database Manager** → **Backup**
2. Download backups regularly
3. Store in secure location (S3, Google Drive, etc.)

---

## Cost Estimates (Railway)

**PostgreSQL**: ~$5-10/month (Hobby plan)
**Odoo Service**: ~$5-10/month (Hobby plan)
**Total**: ~$10-20/month

Free trial includes $5 credit. After trial, you'll need to add a payment method.

---

## Security Best Practices

1. **Use Strong Passwords**: For database user, admin password, and Odoo users
2. **Enable 2FA**: In Odoo user settings
3. **Regular Backups**: Download database backups weekly
4. **Update Regularly**: Redeploy to get latest Odoo security patches
5. **Monitor Logs**: Check for suspicious activity
6. **Limit Admin Access**: Create regular users for day-to-day work

---

## Next Steps

After successful installation:

1. **Install Business Modules**: Go to Apps and install what you need (CRM, Sales, Inventory, etc.)
2. **Configure Company Settings**: Update company name, logo, address
3. **Create Users**: Add team members with appropriate permissions
4. **Import Data**: If migrating, import customers, products, etc.
5. **Customize**: Set up workflows, email templates, reports
6. **Train Users**: Odoo has extensive documentation at https://www.odoo.com/documentation/18.0/

---

## Support Resources

- **Odoo Documentation**: https://www.odoo.com/documentation/18.0/
- **Odoo Community Forum**: https://www.odoo.com/forum/help-1
- **Railway Documentation**: https://docs.railway.app/
- **Railway Discord**: https://discord.gg/railway
- **This Repository**: Check README.md and CLAUDE.md for technical details

---

## Summary

You should now have:
- PostgreSQL 16 running on Railway
- Odoo 18.0 running with persistent storage
- Email configured via Mailgun
- Public URL for access
- Admin access to Odoo

Your Odoo instance is ready for production use!
