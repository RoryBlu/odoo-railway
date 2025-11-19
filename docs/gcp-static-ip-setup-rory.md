# GCP Static IP Setup Guide for Rory
## Why and How to Reserve a Static External IP Address

**Target Audience:** Rory (Human Operator)
**Purpose:** Reserve a static external IP for sparkjar-odoo-001 server
**Prerequisites:** GCP credentials configured (see `gcp-credentials-setup-rory.md`)
**Last Updated:** November 18, 2025

---

## Why You Need a Static IP

### The Problem with Dynamic (Ephemeral) IPs

By default, Google Cloud assigns **ephemeral** (temporary) IP addresses to VMs:
- IP changes every time the VM restarts
- IP is released when VM is deleted
- DNS records become invalid after restart
- SSH config breaks after restart
- External integrations (webhooks, APIs) lose connection

**Reference:** https://cloud.google.com/compute/docs/ip-addresses#ephemeraladdress

### Benefits of Static IPs

A **static external IP** provides:
1. ✅ **Permanent address** - Never changes, even if VM restarts or is recreated
2. ✅ **DNS stability** - Configure A record once, works forever
3. ✅ **SSH reliability** - `ssh sparkjar-odoo-001` always works
4. ✅ **SSL certificates** - Let's Encrypt certificates stay valid
5. ✅ **Webhook reliability** - External services can always reach your server
6. ✅ **Disaster recovery** - Attach same IP to replacement VM

**Cost:** $3.60/month while attached to a running VM (free while attached, $3.60/month if reserved but unattached)

**Reference:** https://cloud.google.com/compute/docs/ip-addresses#reservedaddress

---

## Official Documentation References

- **IP Addresses Overview:** https://cloud.google.com/compute/docs/ip-addresses
- **Reserve Static External IP:** https://cloud.google.com/vpc/docs/reserve-static-external-ip-address
- **Static IP Pricing:** https://cloud.google.com/compute/network-pricing#ipaddress
- **Attach Static IP to Instance:** https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#attach-static-ip

---

## Part 1: Understanding Static IP Concepts

### Static IP Lifecycle

```
Reserve Static IP → Attach to VM → VM Uses IP → Detach from VM → Release IP
      ($3.60/mo       (Free)       (Running)     (Free)        (No charge)
      if unattached)
```

**Key Points:**
- Static IPs are **regional resources** (must match VM region)
- Can be attached to **one VM at a time**
- Can be **detached and reattached** to different VMs
- **Charged $3.60/month** if reserved but not attached
- **Free** when attached to a running VM

**Reference:** https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#billing

### Static IP vs Ephemeral IP Comparison

| Feature | Ephemeral IP | Static IP |
|---------|-------------|-----------|
| Cost | Free | $3.60/mo (if unattached) |
| Stability | Changes on restart | Never changes |
| DNS | Must update A record | Set once, permanent |
| SSL Certs | May need renewal | No issues |
| Disaster Recovery | New IP on rebuild | Same IP on rebuild |
| Webhooks | Break on restart | Always work |
| **Recommended for Production** | ❌ No | ✅ Yes |

---

## Part 2: Reserve Static IP for sparkjar-odoo-001

### Step 2.1: Verify gcloud Configuration

```bash
# Ensure you're authenticated
gcloud auth list

# Confirm project and region
gcloud config list
# Should show:
# project = sparkjar-prod-XXXXXX
# compute/region = us-central1
# compute/zone = us-central1-a
```

### Step 2.2: Reserve Static External IP

**Using gcloud CLI:**
```bash
gcloud compute addresses create sparkjar-odoo-001-ip \
  --region=us-central1 \
  --description="Static IP for SparkJar Odoo production server"
```

**Expected output:**
```
Created [https://www.googleapis.com/compute/v1/projects/sparkjar-prod-XXXXXX/regions/us-central1/addresses/sparkjar-odoo-001-ip].
```

**Reference:** https://cloud.google.com/sdk/gcloud/reference/compute/addresses/create

### Step 2.3: Retrieve the Reserved IP Address

```bash
gcloud compute addresses describe sparkjar-odoo-001-ip \
  --region=us-central1 \
  --format="get(address)"
```

**Example output:**
```
35.192.45.123
```

**Save this IP address** - you'll need it for:
- DNS A record configuration
- SSH config profile
- SSL certificate
- Agent handoff

**Alternative command to see more details:**
```bash
gcloud compute addresses list
```

**Output:**
```
NAME                    ADDRESS/RANGE   TYPE      PURPOSE  NETWORK  REGION       SUBNET  STATUS
sparkjar-odoo-001-ip    35.192.45.123   EXTERNAL                    us-central1          RESERVED
```

**Reference:** https://cloud.google.com/sdk/gcloud/reference/compute/addresses/describe

---

## Part 3: Configure DNS (Recommended)

### Why Configure DNS Now

**Benefits:**
- Access server via domain name: `sparkjar-odoo-001.yourdomain.com`
- SSL certificates require domain names (Let's Encrypt)
- Professional appearance for production systems
- Easier to remember than IP addresses

**When to skip:** If testing only, you can use IP addresses directly.

### Step 3.1: Choose a Domain Name

**Options:**
1. **Subdomain of existing domain:** `sparkjar-odoo-001.sparkjar.agency`
2. **New domain for this project:** `sparkjar.cloud` or similar
3. **Test subdomain:** `odoo-test.yourdomain.com` (for non-production)

**Recommendation:** Use a subdomain of your existing business domain.

### Step 3.2: Create DNS A Record

**For most DNS providers (Cloudflare, Route 53, Google Domains, etc.):**

1. Log into your DNS provider
2. Go to DNS management for your domain
3. Add **A record:**
   - **Type:** A
   - **Name:** `sparkjar-odoo-001` (or `@` for apex domain)
   - **Value:** `35.192.45.123` (your static IP)
   - **TTL:** 300 (5 minutes) initially, increase to 3600 later

**Example for Cloudflare:**
- Log in to Cloudflare dashboard
- Select domain: `sparkjar.agency`
- Go to DNS → Records
- Click **Add record**
- Type: `A`
- Name: `sparkjar-odoo-001`
- IPv4 address: `35.192.45.123`
- Proxy status: **DNS only** (orange cloud off)
- TTL: Auto
- Click **Save**

**Reference (Cloudflare):** https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/

**Reference (Google Cloud DNS):** https://cloud.google.com/dns/docs/records

### Step 3.3: Verify DNS Propagation

**Wait 5-10 minutes, then test:**
```bash
# Using dig (macOS has this by default)
dig sparkjar-odoo-001.yourdomain.com

# Expected output should include:
# ;; ANSWER SECTION:
# sparkjar-odoo-001.yourdomain.com. 300 IN A 35.192.45.123

# Or using nslookup
nslookup sparkjar-odoo-001.yourdomain.com

# Expected output:
# Name:    sparkjar-odoo-001.yourdomain.com
# Address: 35.192.45.123
```

**DNS propagation checker:** https://dnschecker.org/

---

## Part 4: Update SSH Config with Static IP

### Step 4.1: Edit SSH Config

```bash
nano ~/.ssh/config
```

### Step 4.2: Update sparkjar-odoo-001 Profile

**Find this section (from gcp-credentials-setup-rory.md):**
```
Host sparkjar-odoo-001
  HostName STATIC_IP_ADDRESS_HERE
  ...
```

**Update to:**
```
# SparkJar Odoo Production Server
Host sparkjar-odoo-001
  HostName 35.192.45.123
  User r_t_rawlings
  IdentityFile ~/.ssh/sparkjar-odoo-001
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

**Or, if DNS is configured, use domain name:**
```
Host sparkjar-odoo-001
  HostName sparkjar-odoo-001.yourdomain.com
  ...
```

**Save and exit** (Ctrl+O, Enter, Ctrl+X).

### Step 4.3: Test SSH Config

```bash
# This won't connect yet (VM not created), but should show the correct hostname
ssh -G sparkjar-odoo-001 | grep hostname

# Expected output:
# hostname 35.192.45.123
# OR
# hostname sparkjar-odoo-001.yourdomain.com
```

---

## Part 5: Attach Static IP to VM (When VM is Created)

**Note:** This step is performed by the agent during deployment. You don't need to do this manually, but it's documented here for reference.

### Step 5.1: Agent Workflow

**When agent creates the VM, it will:**

1. Create VM with default ephemeral IP:
```bash
gcloud compute instances create sparkjar-odoo-001 \
  --zone=us-central1-a \
  --machine-type=e2-standard-4 \
  # ... other flags ...
```

2. Delete the ephemeral IP:
```bash
gcloud compute instances delete-access-config sparkjar-odoo-001 \
  --access-config-name="external-nat" \
  --zone=us-central1-a
```

3. Attach the static IP:
```bash
gcloud compute instances add-access-config sparkjar-odoo-001 \
  --access-config-name="external-nat" \
  --address=sparkjar-odoo-001-ip \
  --zone=us-central1-a
```

**Reference:** https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#attach-static-ip

### Step 5.2: Verify Static IP is Attached

```bash
gcloud compute instances describe sparkjar-odoo-001 \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

**Expected output:** `35.192.45.123` (your static IP)

---

## Part 6: Cost Management

### Current Costs

**Static IP pricing:**
- **Attached to running VM:** Free
- **Attached to stopped VM:** $3.60/month
- **Reserved but unattached:** $3.60/month

**Total monthly cost for sparkjar-odoo-001:**
- Compute (e2-standard-4): $97.83/month
- Storage (100 GB SSD): $17/month
- **Static IP (attached):** $0/month
- Total: ~$115/month

**Reference:** https://cloud.google.com/compute/network-pricing#ipaddress

### Cost Optimization Tips

**DO:**
- ✅ Keep VM running (static IP is free when attached)
- ✅ Delete unused static IPs (release when no longer needed)
- ✅ Use single static IP per VM

**DON'T:**
- ❌ Stop VM for long periods (static IP becomes charged)
- ❌ Reserve static IPs "just in case" (you pay for unused IPs)

**If you must stop the VM temporarily:**
```bash
# Static IP will cost $3.60/month while VM is stopped
gcloud compute instances stop sparkjar-odoo-001 --zone=us-central1-a

# To avoid the charge, release the static IP first
# (But then you'll need to update DNS when you restart)
```

---

## Part 7: Disaster Recovery with Static IPs

### Scenario: VM Needs to be Rebuilt

**Traditional approach (ephemeral IP):**
1. Delete old VM
2. Create new VM
3. Get new IP address
4. Update DNS A record
5. Wait for DNS propagation (up to 48 hours)
6. Update SSH config
7. Obtain new SSL certificate

**With static IP:**
1. Delete old VM (static IP is automatically detached)
2. Create new VM
3. Attach same static IP
4. Done - DNS, SSH, SSL all still work

**Example recovery workflow:**
```bash
# Delete failed VM
gcloud compute instances delete sparkjar-odoo-001 --zone=us-central1-a

# Create replacement VM (same name)
gcloud compute instances create sparkjar-odoo-001 \
  --zone=us-central1-a \
  --machine-type=e2-standard-4 \
  # ... other flags ...

# Attach the same static IP
gcloud compute instances delete-access-config sparkjar-odoo-001 \
  --access-config-name="external-nat" \
  --zone=us-central1-a

gcloud compute instances add-access-config sparkjar-odoo-001 \
  --access-config-name="external-nat" \
  --address=sparkjar-odoo-001-ip \
  --zone=us-central1-a

# Everything (DNS, SSH, SSL) still works with the same IP!
```

**Reference:** https://cloud.google.com/compute/docs/disaster-recovery

---

## Part 8: Static IP Management Commands

### View All Reserved IPs

```bash
gcloud compute addresses list
```

### Get Specific IP Details

```bash
gcloud compute addresses describe sparkjar-odoo-001-ip \
  --region=us-central1
```

### Check IP Usage

```bash
# See which VM (if any) is using the IP
gcloud compute addresses describe sparkjar-odoo-001-ip \
  --region=us-central1 \
  --format="get(users[0])"
```

**Output examples:**
- If attached: `https://www.googleapis.com/compute/v1/projects/.../instances/sparkjar-odoo-001`
- If unattached: (empty output)

### Release Static IP (Delete)

**⚠️ Warning:** Only do this if you're permanently decommissioning the server!

```bash
gcloud compute addresses delete sparkjar-odoo-001-ip \
  --region=us-central1
```

**Reference:** https://cloud.google.com/sdk/gcloud/reference/compute/addresses/delete

---

## Part 9: Troubleshooting

### Issue: Static IP reservation fails

**Error:** "Quota 'STATIC_ADDRESSES' exceeded"

**Solution:** Check your quota:
```bash
gcloud compute project-info describe --project=$(gcloud config get-value project) \
  | grep -A 2 STATIC_ADDRESSES
```

**Default quota:** 8 static IPs per region. If you hit this limit, either:
1. Release unused static IPs
2. Request quota increase: https://console.cloud.google.com/iam-admin/quotas

**Reference:** https://cloud.google.com/compute/quotas

### Issue: Cannot attach static IP to VM

**Error:** "The IP address is already in use"

**Check if IP is attached elsewhere:**
```bash
gcloud compute addresses describe sparkjar-odoo-001-ip \
  --region=us-central1 \
  --format="get(users)"
```

**Solution:** Detach from the other VM first, or use a different IP.

### Issue: DNS not resolving

**Check DNS propagation:**
```bash
dig sparkjar-odoo-001.yourdomain.com
```

**Common issues:**
- TTL too high (wait for cache expiration)
- A record points to wrong IP
- DNS provider settings not saved
- Cloudflare proxy enabled (should be DNS-only for direct access)

**Fix:** Verify A record in DNS provider, wait 5-10 minutes, test again.

### Issue: SSL certificate fails after IP change

**If you used ephemeral IP and now switched to static:**
```bash
# SSH to server
ssh sparkjar-odoo-001

# Delete old certificate
sudo certbot delete --cert-name sparkjar-odoo-001.yourdomain.com

# Obtain new certificate
sudo certbot --nginx -d sparkjar-odoo-001.yourdomain.com

# Restart nginx
sudo systemctl restart nginx
```

---

## Part 10: What to Provide to Agent

### Information Agent Needs

**After completing this guide, provide to agent:**

1. **Static IP Address:** `35.192.45.123` (your actual IP)
2. **Static IP Name:** `sparkjar-odoo-001-ip`
3. **Region:** `us-central1`
4. **Domain Name (if configured):** `sparkjar-odoo-001.yourdomain.com`

**Update credentials summary file:**
```bash
# Edit the file created in gcp-credentials-setup-rory.md
nano ~/sparkjar-deployment/CREDENTIALS_SUMMARY.txt
```

**Add this section:**
```
STATIC IP INFORMATION:
- Address: 35.192.45.123
- Name: sparkjar-odoo-001-ip
- Region: us-central1
- Status: RESERVED
- Domain: sparkjar-odoo-001.yourdomain.com (if configured)
- DNS A Record: Configured and verified
```

**Agent will use this information to:**
- Attach static IP to newly created VM
- Configure SSH access via domain name
- Obtain SSL certificate for domain
- Configure Nginx with proper server_name

---

## Part 11: Verification Checklist

Before handing off to agent, verify:

- [x] Static IP reserved successfully
- [x] Static IP address saved and documented
- [x] DNS A record created (if using domain)
- [x] DNS propagation verified (`dig` or `nslookup`)
- [x] SSH config updated with static IP or domain
- [x] Credentials summary file updated
- [x] Agent has static IP information

**Test commands:**
```bash
# Verify static IP is reserved
gcloud compute addresses list | grep sparkjar-odoo-001-ip

# Verify DNS (if configured)
dig sparkjar-odoo-001.yourdomain.com

# Verify SSH config
ssh -G sparkjar-odoo-001 | grep hostname
```

---

## Part 12: After Deployment

### Verify Static IP is Attached

**After agent creates VM:**
```bash
gcloud compute instances describe sparkjar-odoo-001 \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

**Should output:** `35.192.45.123` (your static IP)

### Test SSH Access

```bash
ssh sparkjar-odoo-001
# Should connect using your SSH key
```

### Test HTTPS Access

```bash
curl https://sparkjar-odoo-001.yourdomain.com/health
# After deployment completes
```

### Monitor Costs

```bash
# View static IP billing
gcloud compute addresses list --format="table(name,address,status,users)"
```

**Check billing dashboard:** https://console.cloud.google.com/billing

---

## Summary: Why This Matters

**Without static IP:**
- ❌ IP changes on every VM restart
- ❌ DNS breaks, SSL breaks, SSH breaks
- ❌ Manual reconfiguration after every restart
- ❌ Webhooks and integrations break
- ❌ Disaster recovery is painful

**With static IP:**
- ✅ Permanent, never-changing IP address
- ✅ DNS configured once, works forever
- ✅ SSH always works
- ✅ SSL certificates stay valid
- ✅ Webhooks and integrations never break
- ✅ Easy disaster recovery (same IP on new VM)

**Cost:** $3.60/month while attached (essentially free)

**Bottom line:** For a production server hosting business-critical services (SparkJar Hub, Odoo Enterprise), a static IP is **non-negotiable**.

---

## Next Steps

1. ✅ Static IP reserved (this guide)
2. ✅ DNS configured (optional but recommended)
3. ✅ SSH config updated
4. **→ Provide static IP info to agent**
5. **→ Agent creates VM and attaches static IP**
6. **→ Agent deploys SparkJar and Odoo**
7. **→ Test access via SSH and HTTPS**

---

## Official Documentation Links

- **Static IP Overview:** https://cloud.google.com/compute/docs/ip-addresses
- **Reserve Static IP:** https://cloud.google.com/vpc/docs/reserve-static-external-ip-address
- **Attach to Instance:** https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#attach-static-ip
- **Pricing:** https://cloud.google.com/compute/network-pricing#ipaddress
- **gcloud addresses reference:** https://cloud.google.com/sdk/gcloud/reference/compute/addresses

---

**End of GCP Static IP Setup Guide**
