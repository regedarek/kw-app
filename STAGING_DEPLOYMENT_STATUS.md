# kw-app Staging Deployment - COMPLETE ✅

**Date:** 2026-01-16  
**Environment:** Raspberry Pi 5 (pi5main.local)  
**Status:** Successfully deployed and running

## Quick Access
- **URL:** http://pi5main.local (internal network)
- **SSH:** `ssh rege@pi5main.local`
- **Healthcheck:** `curl -H "Host: pi5main.local" http://pi5main.local/up` → Returns `OK`

## Deployed Services
| Service | Image | Status | Port | Container |
|---------|-------|--------|------|-----------|
| App | regedarek/kw-app:8853430a | ✅ Running | 3000 | fa958468f5de |
| Proxy | kamal-proxy:v0.8.4 | ✅ Running | 80/443 | f0f219649c15 |
| PostgreSQL | postgres:16.0 | ✅ Healthy | 5433→5432 | 17389b2e74da |
| Redis | redis:7-alpine | ✅ Healthy | 6381→6379 | 4664afe76067 |

## Key Changes Made
1. **Fixed CarrierWave initializer** - Changed logic to respect `USE_CLOUD_STORAGE=false` in staging (commit `8853430a`)
2. **Configured staging environment** - Added staging database config in `config/database.yml`
3. **Deployed with Kamal** - Zero-downtime deployment using Docker containers

## Configuration
- **Rails env:** staging
- **Storage:** Local file storage (cloud storage disabled)
- **Database:** kw_app_staging @ kw-app-staging-postgres
- **Cache/Jobs:** Redis @ kw-app-staging-redis
- **Networks:** `kamal` (proxy) + `private` (db/redis)

## Deployment Commands
```bash
# Setup Ruby & secrets
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
chruby 3.2.2
set -a && source .kamal/secrets-staging && set +a

# Deploy
kamal deploy -d staging

# Useful commands
kamal app logs -d staging              # View app logs
kamal app exec -d staging 'rails c'    # Rails console
ssh rege@pi5main.local "docker ps"     # Check containers
```

## Logs & Monitoring
```bash
# App logs
ssh rege@pi5main.local "docker logs fa958468f5de -f"

# All services
ssh rege@pi5main.local "docker ps -a"

# Database
ssh rege@pi5main.local "docker logs kw-app-staging-postgres --tail 50"
```

## Infrastructure
- Managed via Ansible: `../kw-app-ansible`
- Prepared with: `ansible-playbook playbooks/prepare-for-kamal.yml`
- Accessories deployed: `ansible-playbook playbooks/deploy-accessories.yml`

## Notes
- **Performance:** Pi on WiFi (~10 Mbps). Consider Ethernet for faster deployments.
- **Secrets:** Stored in `.kamal/secrets-staging` (not committed)
- **Docker Hub:** Images pushed as `regedarek/kw-app:latest-staging` and commit-tagged
- **Local commits:** 5 commits ahead of origin/develop (not pushed)