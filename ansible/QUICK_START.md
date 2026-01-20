# Quick Start: Deploy to Bare Raspberry Pi

Minimal steps to get kw-app running on a fresh Raspberry Pi.

## Prerequisites on Your Local Machine

- Bitwarden CLI installed and logged in
- Ansible installed (`brew install ansible`)
- SSH access to Pi (`ssh rege@pi5main.local`)
- All Bitwarden secrets created (see main README for list)

## Step 1: Unlock Bitwarden

```bash
export BW_SESSION=$(bw unlock --raw)
bw sync --session "$BW_SESSION"
```

## Step 2: Prepare Pi (One-Time Setup)

This installs Docker and configures the Pi:

```bash
cd ~/code/kw-app

ansible-playbook ansible/staging/prepare-for-kamal.yml \
  -i ansible/inventory/staging.ini \
  --extra-vars "ansible_python_interpreter=/usr/bin/python3"
```

**What it does:**
- Installs Docker
- Adds user to docker group
- Logs into Docker Hub
- Creates Kamal directories

**Time:** ~2-3 minutes

## Step 3: Export Secrets

```bash
export KAMAL_REGISTRY_USERNAME=$(bw get username "kw-app-staging-docker-registry" --session "$BW_SESSION")
export KAMAL_REGISTRY_PASSWORD=$(bw get password "kw-app-staging-docker-registry" --session "$BW_SESSION")
export RAILS_MASTER_KEY=$(bw get notes "kw-app-staging-master-key" --session "$BW_SESSION")
export POSTGRES_PASSWORD=$(bw get password "kw-app-staging-database-bootstrap" --session "$BW_SESSION")
export REDIS_PASSWORD=$(bw get password "kw-app-staging-redis-bootstrap" --session "$BW_SESSION")
```

## Step 4: Initial Setup (First Deployment)

```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal setup -c config/deploy.staging.yml'
```

**What it does:**
- Starts kamal-proxy (HTTP router)
- Starts PostgreSQL container
- Starts Redis container
- Builds Docker image locally
- Pushes to Docker Hub
- Deploys app container

**Time:** 10-15 minutes (first build is slow)

## Step 5: Subsequent Deployments

For updates after initial setup:

```bash
# Export secrets (same as Step 3)
export KAMAL_REGISTRY_USERNAME=$(bw get username "kw-app-staging-docker-registry" --session "$BW_SESSION")
export KAMAL_REGISTRY_PASSWORD=$(bw get password "kw-app-staging-docker-registry" --session "$BW_SESSION")
export RAILS_MASTER_KEY=$(bw get notes "kw-app-staging-master-key" --session "$BW_SESSION")
export POSTGRES_PASSWORD=$(bw get password "kw-app-staging-database-bootstrap" --session "$BW_SESSION")
export REDIS_PASSWORD=$(bw get password "kw-app-staging-redis-bootstrap" --session "$BW_SESSION")

# Deploy
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal deploy -c config/deploy.staging.yml'
```

**Time:** 2-3 minutes (uses cache)

## Step 6: Initialize Database

**Note:** Run tasks separately on Pi due to memory constraints.

```bash
# Create database
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.staging.yml "bin/rails db:create"'

# Load schema
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.staging.yml "bin/rails db:schema:load"'

# Seed data (if needed - may fail due to Pi memory, skip if not required)
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.staging.yml "bin/rails db:seed"'
```

## Verify Deployment

```bash
# Check health
curl http://panel.taterniczek.pl/up
# Should return: OK

# Check containers
ssh rege@pi5main.local "docker ps"
# Should show: kamal-proxy, postgres, redis, app

# View logs
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app logs -c config/deploy.staging.yml --lines 50'
```

## Useful Commands

```bash
# Rails console
kamal app exec -c config/deploy.staging.yml -i "bin/rails console"

# Run migrations
kamal app exec -c config/deploy.staging.yml "bin/rails db:migrate"

# Restart app
kamal app boot -c config/deploy.staging.yml

# View all container details
kamal app details -c config/deploy.staging.yml
kamal accessory details all -c config/deploy.staging.yml
```

## Troubleshooting

**Deploy lock error:**
```bash
kamal lock release -c config/deploy.staging.yml
```

**Build fails:**
```bash
# Check Docker Hub login
docker login -u $KAMAL_REGISTRY_USERNAME -p $KAMAL_REGISTRY_PASSWORD
```

**App won't start:**
```bash
# Check logs
kamal app logs -c config/deploy.staging.yml --lines 100
```

**Clean slate:**
```bash
# Remove everything and start over
kamal app remove -c config/deploy.staging.yml
kamal accessory remove all -c config/deploy.staging.yml
kamal proxy remove -c config/deploy.staging.yml

# Then re-run setup
kamal setup -c config/deploy.staging.yml
```

## What's Installed on Pi

**Minimal packages:**
- `docker.io` - Container runtime (required)
- `python3-docker` - For Ansible automation (required for playbook)
- `curl` - Debugging (optional)

**Not needed:**
- ❌ docker-compose - Kamal uses raw Docker
- ❌ build-essential - Building happens on your Mac
- ❌ libpq-dev - App runs in container
- ❌ Node.js - Assets precompiled in Docker image

**Containers running:**
- `kamal-proxy` - HTTP router (ports 80/443)
- `kw-app-staging-postgres` - Database (port 5433)
- `kw-app-staging-redis` - Cache (port 6381)
- `kw-app-staging-web-*` - Rails app

## Summary

```bash
# One-time Pi setup
ansible-playbook ansible/staging/prepare-for-kamal.yml -i ansible/inventory/staging.ini

# Every deployment
export BW_SESSION=$(bw unlock --raw)
# ... export all secrets ...
kamal deploy -c config/deploy.staging.yml
```

That's it! 🚀