# Railway Automation Guide - CLI & API

This guide shows how to use Railway CLI and API with authentication tokens to automate the Odoo deployment process.

---

## Part 1: Get Your Railway API Token

### Step 1: Access Token Page
1. Log into Railway at https://railway.com
2. Go to your account settings
3. Navigate to: **Account Settings** → **Tokens** (https://railway.com/account/tokens)

### Step 2: Create an Account Token
1. Click **"Create Token"** or **"New Token"**
2. Select **"Account Token"** (gives access to all your resources including teams)
3. Give it a name (e.g., "CLI Access" or "API Automation")
4. Click **"Create"**
5. **COPY THE TOKEN IMMEDIATELY** - it's only shown once!

### Token Types Available

| Token Type | Scope | Use Case |
|------------|-------|----------|
| **Account Token** | All your resources + teams | Best for CLI automation |
| **Team Token** | Specific team resources only | Team-specific deployments |
| **Project Token** | Single project/environment | CI/CD pipelines |

**For this guide, use an Account Token** since we'll be creating new projects.

---

## Part 2: Install Railway CLI

### macOS (Homebrew)
```bash
brew install railway
```

### Linux/macOS (Shell Script)
```bash
bash <(curl -fsSL cli.new)
```

### Windows (Scoop)
```bash
scoop install railway
```

### npm (Cross-platform)
```bash
npm i -g @railway/cli
```

**Verify installation:**
```bash
railway --version
```

---

## Part 3: Authenticate Railway CLI

### Option A: Using Environment Variable (Recommended for automation)
```bash
export RAILWAY_API_TOKEN="your-token-here"
```

To make it permanent, add to your shell profile:
```bash
# For bash
echo 'export RAILWAY_API_TOKEN="your-token-here"' >> ~/.bashrc
source ~/.bashrc

# For zsh
echo 'export RAILWAY_API_TOKEN="your-token-here"' >> ~/.zshrc
source ~/.zshrc
```

### Option B: Login Interactively
```bash
railway login
```
This opens a browser window for authentication.

### Verify Authentication
```bash
railway whoami
```
Should display your Railway account email.

---

## Part 4: Automated Deployment Using CLI

### Step 1: Link to Existing Project (meydomo)

If your "meydomo" project already exists:

```bash
# List all your projects
railway list

# Link to the meydomo project
railway link
# Select "meydomo" from the list when prompted
```

Or link directly if you know the project ID:
```bash
railway link [project-id]
```

### Step 2: Add PostgreSQL Database

```bash
# Add PostgreSQL to your project
railway add --database postgres

# Or specify PostgreSQL 17 explicitly
railway add plugin postgresql@17
```

This automatically provisions PostgreSQL and generates environment variables.

### Step 3: Create Odoo Database User

You still need to create the 'odoo' user manually. Get the PostgreSQL connection string:

```bash
# Get database URL
railway variables

# Or connect directly
railway run psql
```

Then run:
```sql
CREATE USER odoo WITH CREATEDB PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE railway TO odoo;
\q
```

### Step 4: Add Odoo Service from GitHub

```bash
# If this repo is already connected to GitHub, add it as a service
railway add --repo r.t.rawlings/odoo-railway
```

Or manually:
1. Go to Railway dashboard
2. Click on "meydomo" project
3. Click **"New"** → **"GitHub Repo"**
4. Select this repository

### Step 5: Set Environment Variables

```bash
# Set variables one by one
railway variables set HOST='${{Postgres.PGHOST}}'
railway variables set PORT='${{Postgres.PGPORT}}'
railway variables set USER=odoo
railway variables set PASSWORD='your-secure-password'
railway variables set POSTGRES_DB=railway

# Mailgun SMTP
railway variables set MAILGUN_SMTP_HOST=smtp.mailgun.org
railway variables set MAILGUN_SMTP_PORT=587
railway variables set MAILGUN_SMTP_USER=your-mailgun-smtp-username
railway variables set MAILGUN_SMTP_PASSWORD=your-mailgun-smtp-password
railway variables set MAILGUN_EMAIL_FROM=noreply@yourdomain.com

# Optional
railway variables set MAILGUN_API_KEY=your-mailgun-api-key
railway variables set MAILGUN_DOMAIN=yourdomain.com
railway variables set ADMIN_PASSWORD='your-admin-password'
```

**Note**: Railway's variable references like `${{Postgres.PGHOST}}` work in the dashboard but may need special handling in CLI. You might need to set these manually in the dashboard.

### Step 6: Deploy

```bash
# If you have the repo locally
railway up

# Or redeploy from dashboard
railway redeploy
```

### Step 7: Get Service URL

```bash
# Generate a public domain
railway domain

# Or view all project info
railway status
```

---

## Part 5: Complete Automation Script

Here's a bash script that automates the entire process:

```bash
#!/bin/bash
# deploy-odoo-railway.sh

set -e  # Exit on error

echo "================================================"
echo "Odoo Railway Automated Deployment"
echo "================================================"
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "Error: Railway CLI is not installed"
    echo "Install with: brew install railway"
    exit 1
fi

# Check authentication
echo "Checking Railway authentication..."
if ! railway whoami &> /dev/null; then
    echo "Error: Not authenticated with Railway"
    echo "Set RAILWAY_API_TOKEN or run: railway login"
    exit 1
fi

echo "✓ Authenticated with Railway"
echo ""

# Prompt for database password
read -s -p "Enter password for Odoo database user: " DB_PASSWORD
echo ""
read -s -p "Confirm password: " DB_PASSWORD_CONFIRM
echo ""

if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords don't match!"
    exit 1
fi

# Link to meydomo project
echo "Linking to meydomo project..."
railway link meydomo

# Add PostgreSQL
echo "Adding PostgreSQL database..."
railway add --database postgres
echo "✓ PostgreSQL added"
echo ""

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready (30 seconds)..."
sleep 30

# Create odoo database user
echo "Creating 'odoo' database user..."
railway run psql << EOF
CREATE USER odoo WITH CREATEDB PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE railway TO odoo;
\q
EOF
echo "✓ Database user created"
echo ""

# Set environment variables
echo "Setting environment variables..."

# Note: These need to be set in Railway dashboard for proper interpolation
echo "Setting database variables..."
railway variables set USER=odoo
railway variables set PASSWORD="$DB_PASSWORD"
railway variables set POSTGRES_DB=railway

echo "Setting Mailgun SMTP variables..."
railway variables set MAILGUN_SMTP_HOST=smtp.mailgun.org
railway variables set MAILGUN_SMTP_PORT=587
railway variables set MAILGUN_SMTP_USER=your-mailgun-smtp-username
railway variables set MAILGUN_SMTP_PASSWORD=your-mailgun-smtp-password
railway variables set MAILGUN_EMAIL_FROM=noreply@yourdomain.com
railway variables set MAILGUN_API_KEY=your-mailgun-api-key
railway variables set MAILGUN_DOMAIN=yourdomain.com

echo "✓ Variables set"
echo ""

echo "IMPORTANT: You must manually set these in Railway dashboard:"
echo "  HOST = \${{Postgres.PGHOST}}"
echo "  PORT = \${{Postgres.PGPORT}}"
echo ""

# Generate domain
echo "Generating public domain..."
railway domain

echo ""
echo "================================================"
echo "Deployment Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Go to Railway dashboard: https://railway.com/project/meydomo"
echo "2. Set HOST and PORT variables (see above)"
echo "3. Add this GitHub repo as a service"
echo "4. Wait for deployment to complete"
echo "5. Access your Odoo instance at the generated URL"
echo ""
```

**To use this script:**
```bash
chmod +x deploy-odoo-railway.sh
./deploy-odoo-railway.sh
```

---

## Part 6: Using Railway GraphQL API Directly

For more control, you can use Railway's GraphQL API directly.

### Authentication
```bash
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header 'Authorization: Bearer YOUR_API_TOKEN_HERE' \
  --header 'Content-Type: application/json' \
  --data '{"query":"query { me { name email } }"}'
```

### Example: Create a Service with GitHub Repo
```bash
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header 'Authorization: Bearer YOUR_API_TOKEN_HERE' \
  --header 'Content-Type: application/json' \
  --data '{
    "query": "mutation { serviceCreate(input: { projectId: \"YOUR_PROJECT_ID\", source: { repo: \"r.t.rawlings/odoo-railway\" } }) { id } }"
  }'
```

### Get Your Project ID
```bash
# List projects and get IDs
curl --request POST \
  --url https://backboard.railway.com/graphql/v2 \
  --header 'Authorization: Bearer YOUR_API_TOKEN_HERE' \
  --header 'Content-Type: application/json' \
  --data '{"query":"query { projects { edges { node { id name } } } }"}'
```

---

## Part 7: CLI Command Reference

### Project Management
```bash
railway init                    # Create new project
railway list                    # List all projects
railway link                    # Link to existing project
railway unlink                  # Unlink from project
railway delete                  # Delete current project
```

### Service Management
```bash
railway add --database postgres # Add PostgreSQL
railway add --database mysql    # Add MySQL
railway add --database redis    # Add Redis
railway add --database mongo    # Add MongoDB
railway add --repo owner/repo   # Add service from GitHub
railway add --image nginx:latest # Add service from Docker image
```

### Variable Management
```bash
railway variables               # List all variables
railway variables set KEY=value # Set a variable
railway variables delete KEY    # Delete a variable
```

### Deployment
```bash
railway up                      # Deploy from local directory
railway deploy                  # Trigger redeploy
railway redeploy                # Redeploy latest
```

### Information
```bash
railway status                  # Show project status
railway logs                    # View service logs
railway logs -f                 # Follow logs (tail)
railway domain                  # Manage domains
railway whoami                  # Show current user
```

### Running Commands
```bash
railway run <command>           # Run command with Railway env vars
railway run psql                # Connect to PostgreSQL
railway run node index.js       # Run your app locally with Railway vars
railway shell                   # Open shell with Railway vars
```

---

## Part 8: Troubleshooting

### "Authentication failed"
```bash
# Check if token is set
echo $RAILWAY_API_TOKEN

# Test authentication
railway whoami

# Re-authenticate
railway login
```

### "Project not found"
```bash
# List all projects
railway list

# Unlink and relink
railway unlink
railway link
```

### "Permission denied"
- Make sure you're using an **Account Token**, not a Project Token
- Team Tokens won't work for creating new projects

### Variable References Not Working
Railway's `${{Postgres.PGHOST}}` syntax only works in the dashboard. For CLI automation:
1. Set basic variables via CLI
2. Set service references in Railway dashboard manually
3. Or get the actual values and set them directly

### Can't Connect to Database
```bash
# Get database connection details
railway variables | grep PG

# Test connection
railway run psql
```

---

## Summary

**Easiest Approach (Hybrid):**
1. Use CLI to create project structure: `railway init`
2. Use CLI to add PostgreSQL: `railway add --database postgres`
3. Use dashboard to connect GitHub repo (visual interface is easier)
4. Use CLI to set most variables: `railway variables set`
5. Use dashboard to set `${{}}` references manually

**Fully Automated:**
- Requires more GraphQL API calls
- Need to inspect network requests from dashboard
- More complex but fully scriptable

**For Your "meydomo" Project:**
Since it already exists, you mainly need to:
1. Link to it: `railway link meydomo`
2. Add services via dashboard or CLI
3. Set variables via CLI or dashboard

Would you like me to create the actual deployment script tailored to your meydomo project?
