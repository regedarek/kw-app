# Fresh Machine Setup Guide - Bitwarden + Kamal Deployment

This guide shows how to set up Kamal deployments with Bitwarden secret management on a fresh machine (staging Pi or production server).

## Architecture Overview

```
┌─────────────────────┐
│  Bitwarden Vault    │ ← Single source of truth for all secrets
│  (vault.bitwarden   │
│   .com)             │
└──────────┬──────────┘
           │
     ┌─────▼─────────────────────────┐
     │                               │
┌────▼────────┐            ┌────────▼────────┐
│  Local Dev  │            │  Server (Pi)    │
│  Machine    │            │  - Node.js      │
│  - bw CLI   │            │  - bw CLI (npm) │
│  - Kamal    │            │  - Docker       │
└─────────────┘            └─────────────────┘
     │                              │
     │    Deploy via Kamal          │
     └──────────────►───────────────┘
```

## Prerequisites

### Required Bitwarden Items

Create these items in your Bitwarden vault:

**Common (shared)**:
- `docker-registry-credentials` (Login type)
  - Username: Docker Hub username
  - Password: Docker Hub password/token

**Per Environment** (staging/production):
- `kw-app-{env}-master-key` (Secure Note)
  - Notes field: Rails master key content
- `kw-app-{env}-database-bootstrap` (Login)
  - Password: PostgreSQL password
- `kw-app-{env}-redis-bootstrap` (Login)
  - Password: Redis password

## Part 1: Local Machine Setup

### 1. Install Bitwarden CLI

```bash
# macOS
brew install bitwarden-cli

# Linux (via npm)
sudo npm install -g @bitwarden/cli

# Verify
bw --version
```

### 2. Login and Unlock Bitwarden

```bash
# Login (first time only)
bw login

# Unlock and export session
export BW_SESSION=$(bw unlock --raw)

# Verify
bw unlock --check
```

### 3. Install Kamal

```bash
gem install kamal
kamal version
```

### 4. Test Secret Fetching

```bash
# Test fetching secrets
./kamal/test-secrets.sh staging
```

## Part 2: Server Setup (Automated via Ansible)

### What the Ansible Playbook Does

The playbook (`ansible/staging/prepare-for-kamal.yml`) automatically:

1. ✅ Installs Docker
2. ✅ Installs Node.js 20.x (required for Bitwarden CLI)
3. ✅ Installs Bitwarden CLI via npm
4. ✅ Installs jq (JSON parsing)
5. ✅ Configures Docker user permissions
6. ✅ Logs into Docker Hub
7. ✅ Creates Kamal directories
8. ✅ (Optional) Configures PostgreSQL roles

### Run Ansible Playbook

```bash
# Unlock Bitwarden first
export BW_SESSION=$(bw unlock --raw)

# Run playbook
cd ansible/staging
ansible-playbook -i inventory.yml prepare-for-kamal.yml

# For PostgreSQL role setup (after deploying accessories)
ansible-playbook -i inventory.yml prepare-for-kamal.yml --tags postgres-roles
```

### Manual Server Setup (if not using Ansible)

If you prefer manual setup:

```bash
# SSH to server
ssh user@your-server

# 1. Install Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# 2. Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 3. Install Bitwarden CLI
sudo npm install -g @bitwarden/cli

# 4. Install jq
sudo apt install -y jq

# 5. Verify installations
node --version
bw --version
jq --version
docker --version

# 6. Re-login to apply docker group
exit
ssh user@your-server
```

## Part 3: Kamal Configuration Files

### File Structure

```
.kamal/
├── secrets.staging          # Fetches secrets from Bitwarden on-the-fly
├── secrets.production        # Fetches secrets from Bitwarden on-the-fly
├── secrets-common           # Deprecated (kept for reference)
├── test-secrets.sh          # Test script
└── hooks/
    └── pre-connect          # Validates Bitwarden is unlocked
```

### How Secrets Work

**Local & CI/CD (same files)**:
```bash
# .kamal/secrets.staging

# Check if secrets already cached
if [ -n "$KAMAL_SECRETS_STAGING_CACHED" ]; then
    return 0
fi

# Ensure Bitwarden is unlocked
if [ -z "$BW_SESSION" ]; then
    echo "❌ Bitwarden is locked"
    echo "   export BW_SESSION=\$(bw unlock --raw)"
    exit 1
fi

# Source common secrets (Docker registry credentials)
source "$(dirname "$0")/secrets-common"

# Fetch environment-specific secrets from Bitwarden
RAILS_MASTER_KEY=$(bw get item "kw-app-staging-master-key" --session "$BW_SESSION" | jq -r '.notes')
POSTGRES_PASSWORD=$(bw get item "kw-app-staging-database-bootstrap" --session "$BW_SESSION" | jq -r '.login.password')
REDIS_PASSWORD=$(bw get item "kw-app-staging-redis-bootstrap" --session "$BW_SESSION" | jq -r '.login.password')

# Mark as cached
export KAMAL_SECRETS_STAGING_CACHED=1
```

**Benefits**:
- ✅ Same file works locally and in CI/CD
- ✅ Secrets cached per deployment (fetched once)
- ✅ Always fresh from Bitwarden
- ✅ No `.local` files to manage

## Part 4: GitHub Actions Setup

### Required GitHub Secrets

Add these **3 secrets** to your repository (Settings → Secrets → Actions):

1. **`BW_CLIENTID`**
   - Get from: https://vault.bitwarden.com → Settings → Security → Keys → View API Key
   - Format: `user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

2. **`BW_CLIENTSECRET`**
   - Same location as above
   - Format: Long alphanumeric string

3. **`BW_PASSWORD`**
   - Your Bitwarden master password

### Workflows

Two workflows are configured:

**1. Test Workflow** (`test-bitwarden-secrets.yml`):
- Manual trigger only
- Tests secret fetching without deploying
- Verifies all secrets are accessible

**2. Deploy Workflow** (`deploy-staging.yml`):
- Triggered on push to `develop` branch
- Fetches secrets from Bitwarden
- Deploys to staging

## Part 5: Deployment Workflow

### First Time Deployment

```bash
# 1. Unlock Bitwarden
export BW_SESSION=$(bw unlock --raw)

# 2. Test secret fetching
./.kamal/test-secrets.sh staging

# 3. Deploy accessories (databases, redis)
kamal accessory boot all -d staging

# 4. Deploy application
kamal deploy -d staging
```

### Subsequent Deployments

```bash
# Unlock Bitwarden (if needed)
export BW_SESSION=$(bw unlock --raw)

# Deploy
kamal deploy -d staging
```

### Pre-Connect Hook

The `.kamal/hooks/pre-connect` automatically checks:
- ✅ Bitwarden CLI is installed
- ✅ jq is installed
- ✅ Bitwarden is unlocked
- ✅ Provides helpful error messages

## Part 6: Troubleshooting

### "Bitwarden is locked"

```bash
# Check status
bw status

# Unlock
export BW_SESSION=$(bw unlock --raw)

# Verify
bw unlock --check
```

### "Item not found"

```bash
# List items
bw list items --session $BW_SESSION | jq -r '.[].name' | grep kw-app

# Check specific item
bw get item kw-app-staging-master-key --session $BW_SESSION
```

### "bw: command not found" on Server

```bash
# Check if Node.js is installed
node --version

# Check if bw is installed
which bw

# Reinstall if needed
sudo npm install -g @bitwarden/cli
```

### GitHub Actions: "Invalid master password"

- Verify `BW_PASSWORD` secret in GitHub is correct
- No extra spaces or characters

### Secrets Not Cached

If secrets are fetched multiple times:
- Check if `KAMAL_SECRETS_*_CACHED` is being exported
- Verify the secrets file has the caching logic

## Part 7: Adding New Secrets

### 1. Add to Bitwarden

Create a new item in Bitwarden vault:
```
Name: kw-app-staging-sendgrid
Type: Login
Password: your-api-key
```

### 2. Update Secrets File

Edit `.kamal/secrets.staging`:
```bash
SENDGRID_API_KEY=$(bw get item "kw-app-staging-sendgrid" --session "$BW_SESSION" | jq -r '.login.password')
```

### 3. Update Deploy Config

Edit `config/deploy.staging.yml`:
```yaml
env:
  secret:
    - SENDGRID_API_KEY
```

### 4. Test

```bash
export BW_SESSION=$(bw unlock --raw)
./.kamal/test-secrets.sh staging
```

## Part 8: Migration from Old Setup

If migrating from `.local` file pattern:

```bash
# 1. Delete old .local files
rm .kamal/secrets*.local

# 2. Test new approach
export BW_SESSION=$(bw unlock --raw)
./.kamal/test-secrets.sh staging

# 3. Deploy
kamal deploy -d staging
```

## Summary

**What's Different from Old Approach**:

| Aspect | Old | New |
|--------|-----|-----|
| **Local secrets** | Run script to generate `.local` files | Fetch on-the-fly from Bitwarden |
| **GitHub secrets** | 8+ individual secrets | 3 Bitwarden credentials |
| **Server setup** | Manual or complex | Automated via Ansible |
| **Caching** | None (regenerate files) | Smart (fetch once per deployment) |
| **Freshness** | Can be stale | Always fresh from Bitwarden |

**Key Benefits**:
- ✅ Single source of truth (Bitwarden)
- ✅ Works on fresh machines easily
- ✅ Same files work locally and in CI
- ✅ Minimal GitHub secret management
- ✅ Automated server setup
- ✅ Smart caching for performance

## Support

If you encounter issues:
1. Check Bitwarden is unlocked: `bw unlock --check`
2. Verify items exist: `bw list items --session $BW_SESSION | jq`
3. Test secret fetching: `./.kamal/test-secrets.sh staging`
4. Review pre-connect hook output
5. Check GitHub Actions logs for CI/CD issues
