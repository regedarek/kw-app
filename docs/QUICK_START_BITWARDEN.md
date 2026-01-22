# Quick Start - Bitwarden Integration Testing

## Prerequisites

1. **Install Bitwarden CLI** (if not already installed):
   ```bash
   brew install bitwarden-cli
   ```

2. **Install jq** (if not already installed):
   ```bash
   brew install jq
   ```

## Local Testing

### Step 1: Unlock Bitwarden

```bash
# Login (first time only)
bw login

# Unlock and export session
export BW_SESSION=$(bw unlock --raw)
```

**Important**: Copy the session token or re-run the export command in your current shell session.

### Step 2: Test Secret Fetching

```bash
# Test staging secrets
./.kamal/test-secrets.sh staging

# Or test production secrets
./.kamal/test-secrets.sh production
```

Expected output:
```
✅ Bitwarden CLI installed
✅ jq installed
✅ Bitwarden is unlocked
📦 Testing secret fetching for staging...
✅ KAMAL_REGISTRY_USERNAME is set (length: XX characters)
✅ KAMAL_REGISTRY_PASSWORD is set (length: XX characters)
✅ RAILS_MASTER_KEY is set (length: 32 characters)
✅ POSTGRES_PASSWORD is set (length: XX characters)
✅ REDIS_PASSWORD is set (length: XX characters)
✅ All secrets fetched successfully!
```

### Step 3: Try Deployment (Optional)

```bash
# Deploy to staging
kamal deploy -d staging

# Or deploy to production
kamal deploy -d production
```

**Note**: Secrets are cached after first fetch, so during deployment Bitwarden is only queried once, making subsequent operations fast.

## GitHub Actions Setup

### Required Secrets

Add these **3 secrets** to GitHub repository (Settings → Secrets and variables → Actions):

1. **`BW_CLIENTID`**
   - Get from: https://vault.bitwarden.com → Settings → Security → Keys → View API Key
   - Format: `user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

2. **`BW_CLIENTSECRET`**
   - Same location as above
   - Format: Long alphanumeric string

3. **`BW_PASSWORD`**
   - Your Bitwarden master password

### Test GitHub Actions

Push to `develop` branch to trigger staging deployment:

```bash
git add .
git commit -m "Test Bitwarden integration"
git push origin develop
```

Watch the workflow in GitHub Actions → "Deploy Staging"

Look for these steps:
- ✅ Install Bitwarden CLI and jq
- ✅ Authenticate with Bitwarden
- ✅ Test secret fetching
- ✅ Deploy to staging

## Troubleshooting

### "Bitwarden is locked"

```bash
# Check status
bw status

# Unlock and export session
export BW_SESSION=$(bw unlock --raw)

# Verify
bw unlock --check
```

### "Item not found"

Verify Bitwarden items exist:

```bash
# List all items
bw list items --session $BW_SESSION | jq -r '.[].name' | grep kw-app

# Should show:
# docker-registry-credentials
# kw-app-staging-master-key
# kw-app-staging-database-bootstrap
# kw-app-staging-redis-bootstrap
# kw-app-production-master-key
# kw-app-production-database-bootstrap
# kw-app-production-redis-bootstrap
```

### "jq: command not found"

```bash
brew install jq
```

### GitHub Actions: "Invalid master password"

- Verify `BW_PASSWORD` secret in GitHub matches your actual password
- No typos, correct capitalization

### GitHub Actions: "Item not found"

- Check item names in Bitwarden match exactly
- Case-sensitive!

## What Changed from Old Approach

### Before ❌
```bash
# Had to run script to generate .local files
./.kamal/bw-fetch-secrets.sh staging

# Then deploy
kamal deploy -d staging
```

### Now ✅
```bash
# Just unlock Bitwarden once
export BW_SESSION=$(bw unlock --raw)

# Deploy directly (fetches secrets automatically)
kamal deploy -d staging
```

**Benefits:**
- No `.local` files to manage
- Always fresh secrets from Bitwarden
- Same workflow locally and in CI
- Fewer GitHub secrets to manage (3 instead of 5+ per environment)
- Smart caching: Secrets fetched once per deployment, not on every Kamal operation

## Performance & Caching

Secrets are automatically cached during a deployment session:
- **First time**: Fetches from Bitwarden (1-2 seconds)
- **Subsequent times**: Uses cached values (instant)
- **Cache scope**: Per shell session (cleared when you close terminal or logout)

This means during a single `kamal deploy` command, Bitwarden is only queried once even though Kamal may source the secrets file multiple times.

## Files Reference

- `.kamal/secrets.staging` - Fetches staging secrets from Bitwarden (with caching)
- `.kamal/secrets.production` - Fetches production secrets from Bitwarden (with caching)
- `.kamal/hooks/pre-connect` - Validates Bitwarden is unlocked before deployment
- `.kamal/test-secrets.sh` - Test script to verify secret fetching
- `.github/workflows/deploy-staging.yml` - Staging deployment with Bitwarden
- `.github/workflows/deploy-production.yml` - Production deployment with Bitwarden

## Next Steps

Once confirmed working:

1. ✅ Test locally with `.kamal/test-secrets.sh`
2. ✅ Add 3 secrets to GitHub
3. ✅ Test GitHub Actions deployment
4. 🗑️ Delete old individual GitHub secrets (optional cleanup):
   - `RAILS_MASTER_KEY_STAGING`
   - `RAILS_MASTER_KEY_PRODUCTION`
   - `POSTGRES_PASSWORD_STAGING`
   - `POSTGRES_PASSWORD_PRODUCTION`
   - `REDIS_PASSWORD_STAGING`
   - `REDIS_PASSWORD_PRODUCTION`
   - `KAMAL_REGISTRY_USERNAME` (now fetched from Bitwarden)
   - `KAMAL_REGISTRY_PASSWORD` (now fetched from Bitwarden)