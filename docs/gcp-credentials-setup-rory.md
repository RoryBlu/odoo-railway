# GCP Credentials Setup Guide for Rory
## Google Cloud Platform Account Configuration and SSH Access

**Target Audience:** Rory (Human Operator)
**Purpose:** Configure GCP credentials and SSH access for AI agents to deploy sparkjar-odoo-001
**Prerequisites:** Google account, Credit card for GCP billing
**Last Updated:** November 18, 2025

---

## Overview

This guide walks you through setting up Google Cloud Platform (GCP) credentials so that Claude Code agents can:
1. Create and manage Compute Engine VMs
2. Configure networking (firewall rules, static IPs)
3. SSH and SCP to the server for deployments
4. Monitor and manage resources via gcloud CLI

**What You'll Create:**
- GCP account with billing enabled
- Service account with Compute Engine permissions
- JSON key file for service account
- SSH key pair for VM access
- gcloud CLI configuration
- SSH config profile `sparkjar-odoo-001`

---

## Official Documentation References

- **GCP Account Creation:** https://cloud.google.com/free
- **Install gcloud CLI:** https://cloud.google.com/sdk/docs/install
- **Authorize gcloud:** https://cloud.google.com/sdk/docs/authorizing
- **Service Accounts:** https://cloud.google.com/iam/docs/service-accounts-create
- **Compute Engine SSH:** https://cloud.google.com/compute/docs/instances/ssh
- **Add SSH Keys to VMs:** https://cloud.google.com/compute/docs/connect/add-ssh-keys

---

## Part 1: Create Google Cloud Account

### Step 1.1: Sign Up for GCP

1. Go to: https://cloud.google.com/free
2. Click **Get started for free**
3. Sign in with your Google account (or create one)
4. Enter billing information (credit card required)
5. Accept Terms of Service

**Note:** GCP offers $300 in free credits for 90 days for new accounts.

**Reference:** https://cloud.google.com/free/docs/free-cloud-features

### Step 1.2: Create a Project

1. Go to: https://console.cloud.google.com/
2. Click **Select a project** → **New Project**
3. **Project name:** `sparkjar-production`
4. **Project ID:** `sparkjar-prod-XXXXXX` (auto-generated, note this down)
5. Click **Create**

**Reference:** https://cloud.google.com/resource-manager/docs/creating-managing-projects

### Step 1.3: Enable Billing

1. Go to: https://console.cloud.google.com/billing
2. Select your project
3. Link billing account if not already linked
4. Set up billing alerts (recommended):
   - Budget amount: $200/month
   - Alert thresholds: 50%, 90%, 100%

**Reference:** https://cloud.google.com/billing/docs/how-to/budgets

---

## Part 2: Install and Configure gcloud CLI

### Step 2.1: Install gcloud CLI

**On macOS (your system):**
```bash
# Download installer
curl https://sdk.cloud.google.com | bash

# Restart shell
exec -l $SHELL

# Verify installation
gcloud --version
```

**Reference:** https://cloud.google.com/sdk/docs/install-sdk

**Expected output:**
```
Google Cloud SDK 456.0.0
bq 2.0.98
core 2024.10.25
gcloud-crc32c 1.0.0
gsutil 5.27
```

### Step 2.2: Initialize gcloud CLI

```bash
gcloud init
```

**Follow prompts:**
1. **Log in:** Yes (opens browser for OAuth)
2. **Select project:** Choose `sparkjar-production`
3. **Default region:** `us-central1` (lowest cost)
4. **Default zone:** `us-central1-a`

**Reference:** https://cloud.google.com/sdk/docs/initializing

### Step 2.3: Verify Configuration

```bash
gcloud config list
```

**Expected output:**
```
[core]
account = your-email@gmail.com
disable_usage_reporting = False
project = sparkjar-prod-XXXXXX

[compute]
region = us-central1
zone = us-central1-a
```

### Step 2.4: Enable Required APIs

```bash
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

**Reference:** https://cloud.google.com/service-usage/docs/enable-disable

---

## Part 3: Create Service Account for Agent Access

### Step 3.1: Create Service Account

**Via gcloud CLI:**
```bash
gcloud iam service-accounts create sparkjar-deployment \
  --display-name="SparkJar Deployment Agent" \
  --description="Service account for Claude Code agent deployments"
```

**Reference:** https://cloud.google.com/iam/docs/service-accounts-create

### Step 3.2: Grant Compute Engine Permissions

```bash
# Get your project ID
PROJECT_ID=$(gcloud config get-value project)

# Grant Compute Admin role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:sparkjar-deployment@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# Grant Service Account User role (required for some operations)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:sparkjar-deployment@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"
```

**Reference:** https://cloud.google.com/compute/docs/access/iam

### Step 3.3: Create and Download JSON Key

```bash
gcloud iam service-accounts keys create ~/sparkjar-gcp-key.json \
  --iam-account=sparkjar-deployment@${PROJECT_ID}.iam.gserviceaccount.com
```

**Output:**
```
created key [abc123...] of type [json] as [/Users/r.t.rawlings/sparkjar-gcp-key.json] for [sparkjar-deployment@sparkjar-prod-XXXXXX.iam.gserviceaccount.com]
```

**Security:** This file grants full Compute Engine access. Keep it secure!

**Reference:** https://cloud.google.com/iam/docs/keys-create-delete

### Step 3.4: Verify Service Account

```bash
cat ~/sparkjar-gcp-key.json | jq '.client_email'
# Should show: sparkjar-deployment@sparkjar-prod-XXXXXX.iam.gserviceaccount.com
```

---

## Part 4: Configure gcloud CLI for Agent Access

### Step 4.1: Authenticate with Service Account

```bash
gcloud auth activate-service-account \
  --key-file=~/sparkjar-gcp-key.json \
  --project=${PROJECT_ID}
```

**Reference:** https://cloud.google.com/sdk/gcloud/reference/auth/activate-service-account

### Step 4.2: Set Default Configuration

```bash
gcloud config set project ${PROJECT_ID}
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

### Step 4.3: Test Service Account Access

```bash
# List Compute Engine instances (should be empty initially)
gcloud compute instances list

# This confirms service account has proper permissions
```

---

## Part 5: Generate SSH Key Pair for VM Access

### Step 5.1: Generate SSH Key

```bash
# Generate Ed25519 SSH key (more secure than RSA)
ssh-keygen -t ed25519 -C "sparkjar-odoo-001-deployment" -f ~/.ssh/sparkjar-odoo-001

# Press Enter for no passphrase (required for agent automation)
# Or set passphrase and configure ssh-agent (more secure but complex)
```

**Output:**
```
Your identification has been saved in /Users/r.t.rawlings/.ssh/sparkjar-odoo-001
Your public key has been saved in /Users/r.t.rawlings/.ssh/sparkjar-odoo-001.pub
```

**Reference:** https://cloud.google.com/compute/docs/connect/create-ssh-keys

### Step 5.2: View Public Key

```bash
cat ~/.ssh/sparkjar-odoo-001.pub
```

**Copy this output** - you'll need it to add to the VM metadata.

**Format:**
```
ssh-ed25519 AAAAC3Nza...rest-of-key... sparkjar-odoo-001-deployment
```

### Step 5.3: Set Proper Permissions

```bash
chmod 600 ~/.ssh/sparkjar-odoo-001
chmod 644 ~/.ssh/sparkjar-odoo-001.pub
```

---

## Part 6: Configure SSH Config Profile

### Step 6.1: Edit SSH Config

```bash
nano ~/.ssh/config
```

### Step 6.2: Add sparkjar-odoo-001 Profile

**Add this section:**
```
# SparkJar Odoo Production Server
Host sparkjar-odoo-001
  HostName STATIC_IP_ADDRESS_HERE
  User r_t_rawlings
  IdentityFile ~/.ssh/sparkjar-odoo-001
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

**Note:** Replace `STATIC_IP_ADDRESS_HERE` with the actual static IP after you reserve it (see `gcp-static-ip-setup-rory.md`).

**Reference:** https://man.openbsd.org/ssh_config

### Step 6.3: Test SSH Config Syntax

```bash
ssh -G sparkjar-odoo-001 | grep -E '(hostname|user|identityfile)'
```

**Expected output:**
```
hostname STATIC_IP_ADDRESS_HERE
user r_t_rawlings
identityfile ~/.ssh/sparkjar-odoo-001
```

---

## Part 7: Prepare for Agent Handoff

### Step 7.1: Create Agent Credentials Directory

```bash
mkdir -p ~/sparkjar-deployment
chmod 700 ~/sparkjar-deployment
```

### Step 7.2: Copy Key Files to Agent Directory

```bash
# Copy service account key
cp ~/sparkjar-gcp-key.json ~/sparkjar-deployment/
chmod 600 ~/sparkjar-deployment/sparkjar-gcp-key.json

# Copy SSH private key
cp ~/.ssh/sparkjar-odoo-001 ~/sparkjar-deployment/
chmod 600 ~/sparkjar-deployment/sparkjar-odoo-001

# Copy SSH public key
cp ~/.ssh/sparkjar-odoo-001.pub ~/sparkjar-deployment/
chmod 644 ~/sparkjar-deployment/sparkjar-odoo-001.pub
```

### Step 7.3: Create Credentials Summary File

```bash
cat > ~/sparkjar-deployment/CREDENTIALS_SUMMARY.txt <<EOF
SparkJar GCP Deployment Credentials
Generated: $(date)

PROJECT ID: ${PROJECT_ID}
REGION: us-central1
ZONE: us-central1-a

SERVICE ACCOUNT: sparkjar-deployment@${PROJECT_ID}.iam.gserviceaccount.com
SERVICE ACCOUNT KEY: ~/sparkjar-deployment/sparkjar-gcp-key.json

SSH KEY PAIR:
- Private: ~/sparkjar-deployment/sparkjar-odoo-001
- Public: ~/sparkjar-deployment/sparkjar-odoo-001.pub

SSH USERNAME: r_t_rawlings

STATIC IP: (to be assigned - see gcp-static-ip-setup-rory.md)

NEXT STEPS:
1. Reserve static IP (see gcp-static-ip-setup-rory.md)
2. Update ~/.ssh/config with static IP
3. Provide credentials to agent for deployment
4. Agent will use these credentials to:
   - Create VM via gcloud
   - Attach static IP
   - SSH to configure services
   - Deploy SparkJar and Odoo

SECURITY NOTES:
- Keep sparkjar-gcp-key.json SECURE - it grants Compute Engine admin access
- Keep SSH private key SECURE - it grants root access to VMs
- Never commit these files to git
- Never share these files publicly
EOF

chmod 600 ~/sparkjar-deployment/CREDENTIALS_SUMMARY.txt
```

### Step 7.4: Verify All Files

```bash
ls -lh ~/sparkjar-deployment/
```

**Expected output:**
```
-rw-------  1 r.t.rawlings  staff   2.3K Nov 18 12:00 sparkjar-gcp-key.json
-rw-------  1 r.t.rawlings  staff   411B Nov 18 12:00 sparkjar-odoo-001
-rw-r--r--  1 r.t.rawlings  staff   102B Nov 18 12:00 sparkjar-odoo-001.pub
-rw-------  1 r.t.rawlings  staff   1.1K Nov 18 12:00 CREDENTIALS_SUMMARY.txt
```

---

## Part 8: Handoff Instructions for Agent

When you're ready to hand off to the agent, provide:

### 8.1: Environment Variables for Agent

**Create agent environment file:**
```bash
cat > ~/sparkjar-deployment/.env.agent <<EOF
# GCP Configuration
GOOGLE_APPLICATION_CREDENTIALS=~/sparkjar-deployment/sparkjar-gcp-key.json
GCP_PROJECT_ID=${PROJECT_ID}
GCP_REGION=us-central1
GCP_ZONE=us-central1-a

# SSH Configuration
SSH_PRIVATE_KEY=~/sparkjar-deployment/sparkjar-odoo-001
SSH_PUBLIC_KEY=~/sparkjar-deployment/sparkjar-odoo-001.pub
SSH_USERNAME=r_t_rawlings

# Server Configuration
SERVER_NAME=sparkjar-odoo-001
STATIC_IP_NAME=sparkjar-odoo-001-ip
MACHINE_TYPE=e2-standard-4
DISK_SIZE=100GB
OS_IMAGE_FAMILY=ubuntu-2404-lts-amd64
OS_IMAGE_PROJECT=ubuntu-os-cloud
EOF

chmod 600 ~/sparkjar-deployment/.env.agent
```

### 8.2: Agent Verification Commands

**Provide these commands to agent to verify credentials:**

```bash
# Verify gcloud authentication
gcloud auth list

# Verify project access
gcloud projects describe ${PROJECT_ID}

# Verify Compute Engine API enabled
gcloud services list --enabled | grep compute

# Verify service account permissions
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:sparkjar-deployment@${PROJECT_ID}.iam.gserviceaccount.com"

# Verify SSH key exists
test -f ~/.ssh/sparkjar-odoo-001 && echo "SSH key found" || echo "SSH key missing"
```

### 8.3: Test Agent Can Create Resources

**Agent should test with a minimal VM:**

```bash
# Create test VM (will delete immediately)
gcloud compute instances create test-agent-access \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2404-lts-amd64 \
  --image-project=ubuntu-os-cloud \
  --metadata=enable-oslogin=FALSE

# Verify it was created
gcloud compute instances list

# Delete it
gcloud compute instances delete test-agent-access --zone=us-central1-a --quiet

echo "Agent credential test successful!"
```

---

## Part 9: Security Best Practices

### 9.1: Credential Storage

**DO:**
- ✅ Store service account key in `~/sparkjar-deployment/` (chmod 600)
- ✅ Store SSH private key in `~/.ssh/` (chmod 600)
- ✅ Use service account for agent automation
- ✅ Rotate service account keys every 90 days

**DON'T:**
- ❌ Commit keys to git repositories
- ❌ Store keys in cloud storage (Dropbox, Drive, etc.)
- ❌ Email or Slack keys
- ❌ Use personal account for automation

**Reference:** https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys

### 9.2: Service Account Permissions

**Current permissions:**
- `roles/compute.admin` - Full Compute Engine access
- `roles/iam.serviceAccountUser` - Can impersonate service accounts

**These are necessary for:**
- Creating/deleting VMs
- Managing firewall rules
- Reserving static IPs
- SSH key management

**Reference:** https://cloud.google.com/compute/docs/access/iam

### 9.3: SSH Key Security

**Best practices:**
- Use Ed25519 keys (more secure than RSA)
- No passphrase for automation (but restrict file permissions)
- Store private key only on trusted machines
- Rotate SSH keys annually
- Use different keys for different projects

**Reference:** https://cloud.google.com/compute/docs/instances/ssh#security_considerations

### 9.4: Audit Logging

**Enable audit logs to track agent actions:**
```bash
# Audit logs are enabled by default for Compute Engine
# View logs at: https://console.cloud.google.com/logs/query
```

**Reference:** https://cloud.google.com/compute/docs/logging/audit-logging

---

## Part 10: Troubleshooting

### Issue: gcloud command not found

**Solution:**
```bash
# Add gcloud to PATH
echo 'export PATH=$PATH:/Users/r.t.rawlings/google-cloud-sdk/bin' >> ~/.zshrc
source ~/.zshrc
```

### Issue: Service account has insufficient permissions

**Check permissions:**
```bash
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:sparkjar-deployment@"
```

**Re-grant permissions:**
```bash
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:sparkjar-deployment@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"
```

### Issue: Cannot SSH to VM after creation

**Check:**
1. SSH key added to VM metadata
2. Firewall allows port 22
3. VM is running (`gcloud compute instances list`)
4. Correct username (r_t_rawlings, not root)

**Test connection:**
```bash
ssh -v -i ~/.ssh/sparkjar-odoo-001 r_t_rawlings@STATIC_IP
```

### Issue: "Permission denied (publickey)" error

**Verify:**
1. SSH private key permissions: `chmod 600 ~/.ssh/sparkjar-odoo-001`
2. SSH public key format is correct
3. Username matches VM metadata

**Reference:** https://cloud.google.com/compute/docs/troubleshooting/troubleshooting-ssh

---

## Part 11: Cost Management

### 11.1: Set Up Billing Alerts

1. Go to: https://console.cloud.google.com/billing/budgets
2. Click **Create Budget**
3. **Name:** SparkJar Production Budget
4. **Amount:** $200/month
5. **Thresholds:** 50%, 90%, 100%
6. **Email:** your-email@domain.com
7. Click **Finish**

**Reference:** https://cloud.google.com/billing/docs/how-to/budgets

### 11.2: Monitor Costs

**Check current charges:**
```bash
# Via CLI
gcloud beta billing accounts list

# Via Console
open https://console.cloud.google.com/billing
```

**View cost breakdown:**
- Compute Engine instances
- Persistent disk storage
- Static IP addresses
- Egress (data transfer out)

**Reference:** https://cloud.google.com/billing/docs/how-to/export-data-bigquery

### 11.3: Cost Optimization Tips

- Use committed use discounts (37% savings for 1-year)
- Delete unused disks and snapshots
- Release unused static IPs ($3.60/month each)
- Stop (don't delete) VMs during testing
- Use `e2` machine types (most cost-effective)

**Reference:** https://cloud.google.com/compute/docs/instances/signing-up-committed-use-discounts

---

## Part 12: What to Provide to Agent

When ready to begin deployment, provide the agent with:

### Required Files:
1. **Service account key:** `~/sparkjar-deployment/sparkjar-gcp-key.json`
2. **SSH private key:** `~/sparkjar-deployment/sparkjar-odoo-001`
3. **SSH public key:** `~/sparkjar-deployment/sparkjar-odoo-001.pub`
4. **Environment variables:** `~/sparkjar-deployment/.env.agent`
5. **Credentials summary:** `~/sparkjar-deployment/CREDENTIALS_SUMMARY.txt`

### Required Information:
- **GCP Project ID:** (from `gcloud config get-value project`)
- **Static IP Address:** (after completing `gcp-static-ip-setup-rory.md`)
- **SSH Username:** `r_t_rawlings`
- **Server Name:** `sparkjar-odoo-001`

### Agent Workflow:
1. Agent authenticates with service account key
2. Agent creates VM using gcloud CLI
3. Agent attaches static IP to VM
4. Agent adds SSH public key to VM metadata
5. Agent SSHs to VM using private key
6. Agent deploys SparkJar and Odoo following deployment guides

---

## Success Checklist

Before handing off to agent, verify:

- [x] GCP account created and billing enabled
- [x] gcloud CLI installed and initialized
- [x] Service account created with Compute Admin role
- [x] Service account JSON key downloaded
- [x] SSH key pair generated (Ed25519)
- [x] SSH config profile created for sparkjar-odoo-001
- [x] All credential files in `~/sparkjar-deployment/` with correct permissions
- [x] Test VM creation successful (agent can create resources)
- [x] Billing alerts configured ($200/month budget)
- [x] Static IP reserved (see `gcp-static-ip-setup-rory.md`)
- [x] SSH config updated with static IP address

---

## Next Steps

1. **Complete static IP setup** (see `gcp-static-ip-setup-rory.md`)
2. **Update SSH config** with static IP address
3. **Provide credentials to agent:**
   - Share `~/sparkjar-deployment/` directory path
   - Confirm agent has access to files
4. **Agent begins deployment:**
   - Creates sparkjar-odoo-001 VM
   - Deploys SparkJar Hub
   - Deploys Odoo 19 Enterprise + MCP Bridge
5. **Monitor deployment progress** via agent reports

---

## Support and References

**Official GCP Documentation:**
- Main docs: https://cloud.google.com/docs
- Compute Engine: https://cloud.google.com/compute/docs
- IAM & Service Accounts: https://cloud.google.com/iam/docs
- gcloud CLI: https://cloud.google.com/sdk/gcloud

**GCP Support:**
- Console: https://console.cloud.google.com/
- Support tickets: https://cloud.google.com/support
- Community forums: https://www.googlecloudcommunity.com/

**Questions?**
- Review the agent deployment guides
- Check GCP documentation
- Verify credential file permissions and paths

---

**End of GCP Credentials Setup Guide**
