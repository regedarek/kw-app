# Kamal Secrets with Bitwarden Integration

This directory contains Kamal configuration and secrets files that dynamically fetch credentials from Bitwarden.

## Prerequisites

1. **Bitwarden CLI** - Install if not present:
   ```bash
   brew install bitwarden-cli
   ```

2. **jq** - JSON parser (required for extracting secrets):
   ```bash
   brew install jq
   ```

## Quick Start

### 1. Unlock Bitwarden

Before running any Kamal commands, unlock your Bitwarden vault **manually in your terminal**:

```bash
# Unlock and get session token
bw unlock

# Copy and run the export command it provides:
export BW_SESSION="your-session-token-here"
```

**Important:** The unlock helper script won't work in automated environments. Always unlock manually and export the session token.

### 2. Verify Secrets Access

Test that secrets can be fetched:

```bash
kamal secrets print -d production
kamal secrets print -d staging
```

### 3. Deploy

```bash
# First time deployment
kamal setup -d production

# Subsequent deployments
kamal deploy -d production
```

## Bitwarden Items Structure

Secrets are stored in Bitwarden items under the "KW APP" folder:

### Production Items

- **docker-registry-credentials**
  - Type: Login
  - Username: Docker Hub username
  - Password: Docker Hub access token

- **kw-app-production-master-key**
  - Type: Secure Note
  - Notes field: Rails master key content

- **kw-app-production-database-bootstrap**
  - Type: Login
  - Username: production_user
  - Password: PostgreSQL password

- **kw-app-production-redis-bootstrap**
  - Type: Login
  - Password: Redis password

### Staging Items

- **kw-app-staging-docker-registry**
- **kw-app-staging-master-key**
- **kw-app-staging-database-bootstrap**
- **kw-app-staging-redis-bootstrap**

(Same structure as production items)

## Secrets Files

### `.kamal/secrets-common`
Shared secrets across all environments (currently using production Docker registry).

### `.kamal/secrets.production`
Production-specific secrets fetched from Bitwarden.

### `.kamal/secrets.staging`
Staging-specific secrets fetched from Bitwarden.

## How It Works

Secrets files use command substitution with direct `bw` CLI commands to fetch values dynamically:

```bash
# Example from secrets.production
RAILS_MASTER_KEY=$(bw get item kw-app-production-master-key | jq -r '.notes')
POSTGRES_PASSWORD=$(bw get item kw-app-production-database-bootstrap | jq -r '.login.password')
KAMAL_REGISTRY_USERNAME=$(bw get item docker-registry-credentials | jq -r '.login.username')
```

When you run `kamal deploy`, Kamal executes these shell commands in the secrets files and injects the fetched values into containers as environment variables.

**Why direct `bw` commands instead of `kamal secrets fetch`?**
- Direct `bw` commands are simpler and more reliable
- Works with standard Bitwarden item structures (Login items with username/password)
- No need to configure custom fields or item structures
- Full control over JSON parsing with `jq`

## Troubleshooting

### "Failed to login to and unlock Bitwarden"

**Solution:** Unlock your vault and export BW_SESSION:
```bash
source .kamal/bw-unlock.sh
```

### "command not found: bw"

**Solution:** Install Bitwarden CLI:
```bash
brew install bitwarden-cli
```

### "command not found: jq"

**Solution:** Install jq:
```bash
brew install jq
```

### Session expired during deployment

**Solution:** Sessions expire after inactivity. Re-unlock:
```bash
bw unlock
export BW_SESSION="new-token"
```

### Testing individual secret fetches

```bash
# Test fetching Docker password
bw get item docker-registry-credentials | jq -r '.login.password'

# Test fetching Rails master key
bw get item kw-app-production-master-key | jq -r '.notes'

# Test fetching database password
bw get item kw-app-production-database-bootstrap | jq -r '.login.password'
```

## Security Notes

1. **Never commit secrets files with actual values** - These files with `$(bw ...)` commands are safe to commit
2. **Session tokens are sensitive** - Don't share BW_SESSION values
3. **Lock vault when done** - Run `bw lock` after deployments
4. **Use separate Bitwarden items** - Keep production and staging secrets isolated

## CI/CD Integration (Future)

For GitHub Actions or other CI/CD:

1. Store BW_SESSION as a repository secret (expires, so use service accounts)
2. Use Bitwarden's service account feature for long-lived access
3. Install `bw` CLI and `jq` in CI environment
4. Unlock with: `bw unlock --passwordenv BW_PASSWORD`
5. Export session token before running Kamal commands

## Common Workflows

### Deploy to production
```bash
source .kamal/bw-unlock.sh
kamal deploy -d production
```

### Deploy to staging
```bash
source .kamal/bw-unlock.sh
kamal deploy -d staging
```

### Check what secrets will be used
```bash
source .kamal/bw-unlock.sh
kamal secrets print -d production
```

### Lock vault after deployment
```bash
bw lock
unset BW_SESSION
```
