# Server Provisioning

Fresh server setup for staging (Raspberry Pi) and production (VPS).

---

## Prerequisites

- Bitwarden CLI (`brew install bitwarden-cli`)
- Ansible (`brew install ansible`)
- SSH access to target server
- Docker Hub account

---

## Fresh Staging Setup (Raspberry Pi)

### 1. Unlock Bitwarden
```bash
export BW_SESSION=$(bw unlock --raw)
bw sync --session "$BW_SESSION"
```

### 2. Provision Server (One-Time)
```bash
cd ~/code/kw-app

ansible-playbook ansible/staging/prepare-for-kamal.yml \
  -i ansible/inventory/staging.ini \
  --extra-vars "ansible_python_interpreter=/usr/bin/python3"
```
Installs: Docker, configures user, creates directories (~3 min)

### 3. Export Secrets
```bash
export KAMAL_REGISTRY_USERNAME=$(bw get username "kw-app-staging-docker-registry" --session "$BW_SESSION")
export KAMAL_REGISTRY_PASSWORD=$(bw get password "kw-app-staging-docker-registry" --session "$BW_SESSION")
export RAILS_MASTER_KEY=$(bw get notes "kw-app-staging-master-key" --session "$BW_SESSION")
export POSTGRES_PASSWORD=$(bw get password "kw-app-staging-database-bootstrap" --session "$BW_SESSION")
export REDIS_PASSWORD=$(bw get password "kw-app-staging-redis-bootstrap" --session "$BW_SESSION")
```

### 4. Initial Deploy
```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal setup -c config/deploy.staging.yml'
```
Starts: kamal-proxy, PostgreSQL, Redis, app (~15 min first time)

### 5. Initialize Database
```bash
# Create & load schema
kamal app exec -c config/deploy.staging.yml "bin/rails db:create"
kamal app exec -c config/deploy.staging.yml "bin/rails db:schema:load"

# Seed (optional - may fail on Pi due to memory)
kamal app exec -c config/deploy.staging.yml "bin/rails db:seed"
```

### 6. Verify
```bash
curl http://panel.taterniczek.pl/up  # Should return: OK
ssh rege@pi5main.local "docker ps"    # Should show 4 containers
```

---

## Fresh Production Setup (VPS)

Same steps as staging, but use:
- `ansible/production/prepare-for-kamal.yml`
- `ansible/inventory/production.ini`
- `config/deploy.production.yml`
- Production Bitwarden items (change `staging` to `production` in secret names)

---

## Subsequent Deploys

```bash
# Export secrets (Step 3)
export BW_SESSION=$(bw unlock --raw)
# ... export all 5 secrets ...

# Deploy
kamal deploy -c config/deploy.staging.yml    # or production.yml
```

---

## Common Commands

```bash
# Rails console
kamal app exec --reuse -c config/deploy.staging.yml "bin/rails console"

# Logs
kamal app logs -c config/deploy.staging.yml --lines 50

# Migrations
kamal app exec -c config/deploy.staging.yml "bin/rails db:migrate"

# Restart
kamal app boot -c config/deploy.staging.yml

# Container status
kamal app details -c config/deploy.staging.yml
```

---

## Troubleshooting

**Deploy locked:**
```bash
kamal lock release -c config/deploy.staging.yml
```

**Build fails:**
```bash
docker login -u $KAMAL_REGISTRY_USERNAME -p $KAMAL_REGISTRY_PASSWORD
```

**Fresh start:**
```bash
kamal app remove -c config/deploy.staging.yml
kamal accessory remove all -c config/deploy.staging.yml
kamal proxy remove -c config/deploy.staging.yml
kamal setup -c config/deploy.staging.yml
```

---

## What Gets Installed

**Packages:** `docker.io`, `python3-docker`, `curl`

**Containers:**
- `kamal-proxy` - HTTP router (80/443)
- `kw-app-staging-postgres` - Database (5433)
- `kw-app-staging-redis` - Cache (6381)
- `kw-app-staging-web-*` - Rails app

**Not needed:** docker-compose, build tools, Node.js (all in container)