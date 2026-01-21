# Production Deployment Implementation Plan

## Overview

Deploy kw-app to new Ubuntu VPS at `146.59.44.70` using Kamal and Ansible.

**Target:** `ubuntu@146.59.44.70`  
**Domain:** `nowypanel.kw.krakow.pl`  
**Architecture:** amd64 (vs staging's arm64)

---

## Phase 1: Server Security Hardening

### 1.1 Security Checklist

**Critical security measures to implement:**

1. **Firewall (UFW)** - Only allow ports 22, 80, 443
2. **SSH Hardening** - Disable password auth, key-only access
3. **Fail2ban** - Brute force protection
4. **Unattended Upgrades** - Automatic security updates
5. **Disable Root Login** - Force sudo usage
6. **Swap File** - Memory management (2GB recommended)
7. **Timezone Configuration** - Proper log timestamps (Europe/Warsaw)
8. **System Limits** - Prevent resource exhaustion

### 1.2 Security Tasks in Ansible

These will be added to `prepare-for-kamal.yml`:

**Firewall Configuration:**
```yaml
- name: Install UFW
  apt:
    name: ufw
    state: present

- name: Allow SSH
  ufw:
    rule: allow
    port: '22'
    proto: tcp

- name: Allow HTTP
  ufw:
    rule: allow
    port: '80'
    proto: tcp

- name: Allow HTTPS
  ufw:
    rule: allow
    port: '443'
    proto: tcp

- name: Enable UFW
  ufw:
    state: enabled
    policy: deny
```

**SSH Hardening:**
```yaml
- name: Disable password authentication
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PasswordAuthentication'
    line: 'PasswordAuthentication no'
    
- name: Disable root login
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: '^#?PermitRootLogin'
    line: 'PermitRootLogin no'
    
- name: Restart SSH
  systemd:
    name: ssh
    state: restarted
```

**Fail2ban:**
```yaml
- name: Install fail2ban
  apt:
    name: fail2ban
    state: present
    
- name: Start fail2ban
  systemd:
    name: fail2ban
    enabled: yes
    state: started
```

**Auto Updates:**
```yaml
- name: Install unattended-upgrades
  apt:
    name: unattended-upgrades
    state: present
    
- name: Enable automatic updates
  copy:
    content: |
      APT::Periodic::Update-Package-Lists "1";
      APT::Periodic::Unattended-Upgrade "1";
      APT::Periodic::AutocleanInterval "7";
    dest: /etc/apt/apt.conf.d/20auto-upgrades
```

**Swap File:**
```yaml
- name: Check if swap exists
  stat:
    path: /swapfile
  register: swap_file

- name: Create swap file
  command: fallocate -l 2G /swapfile
  when: not swap_file.stat.exists

- name: Set swap permissions
  file:
    path: /swapfile
    mode: '0600'

- name: Make swap
  command: mkswap /swapfile
  when: not swap_file.stat.exists

- name: Enable swap
  command: swapon /swapfile
  when: not swap_file.stat.exists

- name: Add swap to fstab
  lineinfile:
    path: /etc/fstab
    line: '/swapfile none swap sw 0 0'
    state: present
```

---

## Phase 2: Ansible Production Playbook

### 2.1 Create Inventory File

**File:** `ansible/inventory/production.ini`

```ini
[production_vps]
146.59.44.70 ansible_user=ubuntu

[production_vps:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 2.2 Create Bitwarden Variables

**File:** `ansible/production/vars/bitwarden_refs.yml`

```yaml
---
# Bitwarden item references
bw_vps_sudo: "kw-app-production-vps-sudo"
bw_docker_registry: "kw-app-production-docker-registry"
bw_rails_master_key: "kw-app-production-master-key"
bw_db_bootstrap: "kw-app-production-database-bootstrap"

# Server configuration
production_host: "146.59.44.70"
production_hostname: "nowypanel.kw.krakow.pl"
production_user: "ubuntu"

# Container versions
postgres_version: "16.0"
redis_version: "7-alpine"

# Database configuration
database_name: "kw_app_production"
database_user: "production_user"

# Docker network
docker_network: "kamal"
```

### 2.3 Create Preparation Playbook

**File:** `ansible/production/prepare-for-kamal.yml`

Based on staging playbook but adapted for:
- User: `ubuntu` (not `rege`)
- Host: `146.59.44.70` (not `pi5main.local`)
- Bitwarden refs: production items
- No memory constraints (full VPS vs Pi)
- Network: explicit `kamal` network creation

**Task order:**
1. **Security first** (firewall, SSH, fail2ban, swap, updates)
2. Install Docker + python3-docker
3. Add ubuntu to docker group
4. Create kamal directories
5. Login to Docker Hub
6. Create Docker network `kamal`
7. Pull kamal-proxy image

---

## Phase 3: Bitwarden Secret Setup

### 3.1 Required Secrets

Create in Bitwarden vault:

| Item Name | Type | Content |
|-----------|------|---------|
| `kw-app-production-vps-sudo` | Password | Ubuntu sudo password |
| `kw-app-production-docker-registry` | Login | Docker Hub username/password |
| `kw-app-production-master-key` | Note | Rails master key from `config/credentials/production.key` |
| `kw-app-production-database-bootstrap` | Password | PostgreSQL password (strong, random) |

### 3.2 Verification Command

```bash
export BW_SESSION=$(bw unlock --raw)
bw sync --session "$BW_SESSION"

# Test each item
bw get password "kw-app-production-vps-sudo" --session "$BW_SESSION"
bw get username "kw-app-production-docker-registry" --session "$BW_SESSION"
bw get notes "kw-app-production-master-key" --session "$BW_SESSION"
bw get password "kw-app-production-database-bootstrap" --session "$BW_SESSION"
```

---

## Phase 4: DNS & SSL Configuration

### 4.1 DNS Setup

Point `nowypanel.kw.krakow.pl` to `146.59.44.70`:

```
A     nowypanel.kw.krakow.pl  →  146.59.44.70
```

**Verify:**
```bash
dig nowypanel.kw.krakow.pl +short
# Should return: 146.59.44.70
```

### 4.2 SSL Certificate

SSL is handled by **Cloudflare** (proxy enabled).

**Cloudflare Settings:**
- SSL/TLS mode: **Full (strict)** or **Full**
- Proxy status: **Proxied** (orange cloud)
- Auto HTTPS Rewrites: Enabled

**Kamal Configuration:**
- `ssl: true` in `deploy.production.yml`
- Kamal proxy will serve HTTPS
- Cloudflare terminates SSL at edge, then re-encrypts to origin

**No manual certificate needed** - Cloudflare provides SSL automatically.

---

## Phase 5: Server Preparation

### 5.1 Initial SSH Access Test

**IMPORTANT:** Ensure you have SSH key-based access before running Ansible!

```bash
# Copy your SSH key to server (only needed once)
ssh-copy-id ubuntu@146.59.44.70

# Test access
ssh ubuntu@146.59.44.70
```

⚠️ **Warning:** Ansible will disable password authentication. Make sure SSH keys work first!

### 5.2 Initial Server Check

```bash
ssh ubuntu@146.59.44.70
# Verify sudo access
sudo whoami  # Should return: root
exit
```

### 5.3 Run Ansible Playbook

```bash
cd ~/code/kw-app

# Unlock Bitwarden
export BW_SESSION=$(bw unlock --raw)
bw sync --session "$BW_SESSION"

# Run preparation playbook
ansible-playbook ansible/production/prepare-for-kamal.yml \
  -i ansible/inventory/production.ini \
  --extra-vars "ansible_python_interpreter=/usr/bin/python3"
```

**Expected outcome:**

**Security:**
- ✅ UFW firewall enabled (ports 22, 80, 443 only)
- ✅ SSH password auth disabled (keys only)
- ✅ Root login disabled
- ✅ Fail2ban installed & running
- ✅ Unattended security updates enabled
- ✅ 2GB swap file created
- ✅ Timezone set to Europe/Warsaw

**Docker & Kamal:**
- ✅ Docker installed & running
- ✅ ubuntu user in docker group
- ✅ Kamal directories created
- ✅ Docker Hub login configured
- ✅ Kamal network created

**Time:** ~5-7 minutes

---

## Phase 6: Kamal Deployment

### 6.1 Export Secrets

```bash
export BW_SESSION=$(bw unlock --raw)

export KAMAL_REGISTRY_USERNAME=$(bw get username "kw-app-production-docker-registry" --session "$BW_SESSION")
export KAMAL_REGISTRY_PASSWORD=$(bw get password "kw-app-production-docker-registry" --session "$BW_SESSION")
export RAILS_MASTER_KEY=$(bw get notes "kw-app-production-master-key" --session "$BW_SESSION")
export POSTGRES_PASSWORD=$(bw get password "kw-app-production-database-bootstrap" --session "$BW_SESSION")
```

### 6.2 Initial Setup

```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal setup -c config/deploy.production.yml'
```

**What happens:**
1. Builds Docker image (amd64 arch)
2. Pushes to Docker Hub
3. Starts kamal-proxy with SSL
4. Starts PostgreSQL container
5. Deploys app container
6. Registers with proxy

**Time:** 10-15 minutes (first build)

### 6.3 Database Initialization

```bash
# Create database
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.production.yml -T "bin/rails db:create"'

# Load schema
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.production.yml -T "bin/rails db:schema:load"'

# Run seeds (if needed)
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.production.yml -T "bin/rails db:seed"'
```

---

## Phase 7: Verification & Testing

### 7.1 Health Check

```bash
curl https://nowypanel.kw.krakow.pl/up
# Expected: "OK"
```

### 7.2 SSL Certificate Check

```bash
curl -vI https://nowypanel.kw.krakow.pl 2>&1 | grep -i "cloudflare"
# Should show Cloudflare in headers
```

### 7.3 Security Verification

```bash
ssh ubuntu@146.59.44.70

# Check firewall
sudo ufw status
# Should show: Status: active, ports 22/80/443 allowed

# Check fail2ban
sudo systemctl status fail2ban
# Should be: active (running)

# Check swap
free -h
# Should show 2GB swap

# Test password auth is disabled (should fail)
exit
ssh -o PreferredAuthentications=password ubuntu@146.59.44.70
# Should be rejected
```

### 7.4 Container Status

```bash
ssh ubuntu@146.59.44.70 "docker ps"
```

**Expected containers:**
- `kamal-proxy`
- `kw-app-postgres`
- `kw-app-web-*`

### 7.5 Application Logs

```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app logs -c config/deploy.production.yml --lines 50'
```

### 7.6 Rails Console Test

```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -c config/deploy.production.yml -i "bin/rails console"'
```

```ruby
# In console
User.count
Rails.env  # Should be: production
```

---

## Phase 8: Post-Deployment Configuration

### 8.1 Add Redis (if needed)

Update `config/deploy.production.yml`:

```yaml
accessories:
  postgres:
    # ... existing config ...
  
  redis:
    image: redis:7-alpine
    host: 146.59.44.70
    port: "127.0.0.1:6379:6379"
    env:
      secret:
        - REDIS_PASSWORD
    cmd: sh -c 'redis-server --requirepass "$$REDIS_PASSWORD" --appendonly yes --dir /data'
    directories:
      - redis-data:/data
    options:
      network: "kamal"
```

Add to Bitwarden: `kw-app-production-redis-bootstrap`

Deploy accessory:
```bash
kamal accessory boot redis -c config/deploy.production.yml
```

### 8.2 Configure Backups

SSH to server and create backup script:

```bash
ssh ubuntu@146.59.44.70

cat > ~/backup-database.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec kw-app-postgres pg_dump -U production_user kw_app_production | gzip > /home/ubuntu/backups/db_${DATE}.sql.gz
find /home/ubuntu/backups -name "db_*.sql.gz" -mtime +7 -delete
EOF

chmod +x ~/backup-database.sh
mkdir -p ~/backups

# Add to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ubuntu/backup-database.sh") | crontab -
```

### 8.3 Monitoring Setup

**AppSignal** (already configured):
- Error tracking
- Performance monitoring
- Host metrics
- Alerting

Verify AppSignal env vars in Rails credentials:
```bash
kamal app exec -c config/deploy.production.yml -i "bin/rails console"
```

```ruby
Rails.application.credentials.appsignal
```

**Additional monitoring:**
- Uptime checks (UptimeRobot, Pingdom) - optional
- Cloudflare Analytics (included)

---

## Quick Reference Commands

### Deploy Updates
```bash
export BW_SESSION=$(bw unlock --raw)
# ... export all secrets ...
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal deploy -c config/deploy.production.yml'
```

### Run Migrations
```bash
kamal app exec -c config/deploy.production.yml -T "bin/rails db:migrate"
```

### View Logs
```bash
kamal app logs -c config/deploy.production.yml -f
```

### Rails Console
```bash
kamal app exec -c config/deploy.production.yml -i "bin/rails console"
```

### Restart App
```bash
kamal app boot -c config/deploy.production.yml
```

### Release Deploy Lock
```bash
kamal lock release -c config/deploy.production.yml
```

---

## Differences from Staging

| Aspect | Staging | Production |
|--------|---------|------------|
| Host | pi5main.local | 146.59.44.70 |
| User | rege | ubuntu |
| Arch | arm64 | amd64 |
| SSL | false | true |
| Domain | panel.taterniczek.pl | nowypanel.kw.krakow.pl |
| Postgres Port | 5433 (exposed) | 5432 (localhost only) |
| Redis Port | 6381 (exposed) | 6379 (localhost only) |
| Memory | Limited (Pi) | Full VPS |
| Service Name | kw-app-staging | kw-app |

---

## Rollback Plan

If deployment fails:

```bash
# Check previous containers
kamal app containers -c config/deploy.production.yml

# Rollback to previous version
kamal app rollback -c config/deploy.production.yml

# Or remove everything and redeploy
kamal app remove -c config/deploy.production.yml
kamal accessory remove all -c config/deploy.production.yml
kamal proxy remove -c config/deploy.production.yml

# Then setup again
kamal setup -c config/deploy.production.yml
```

---

## Security Checklist

### Server Hardening
- [ ] UFW firewall enabled (only 22, 80, 443)
- [ ] SSH key-based auth only (password auth disabled)
- [ ] Root login disabled
- [ ] Fail2ban installed and running
- [ ] Unattended security updates enabled
- [ ] Swap file configured (2GB)
- [ ] Timezone set correctly

### Application Security
- [ ] Postgres not exposed publicly (localhost only)
- [ ] Redis not exposed publicly (localhost only)
- [ ] Strong database passwords in Bitwarden
- [ ] Rails credentials encrypted
- [ ] SSL certificate active (Cloudflare)

### Operations
- [ ] Regular security updates scheduled (auto)
- [ ] Backup strategy implemented
- [ ] Monitoring alerts configured (AppSignal)
- [ ] Docker containers auto-restart on failure

---

## Next Steps

1. **Phase 1:** Security hardening plan
2. **Phase 2:** Create Ansible files
3. **Phase 3:** Setup Bitwarden secrets
4. **Phase 4:** Configure DNS
5. **Phase 5:** Run Ansible playbook (security + Docker)
6. **Phase 6:** Deploy with Kamal
7. **Phase 7:** Verify deployment & security
8. **Phase 8:** Configure backups & monitoring

**Future Enhancement:**
- **Phase 9:** GitHub Actions CI/CD (can be added later after manual deployment works)

---

## Additional Security Considerations

### SSH Port Change (Optional)
If you want extra obscurity:
```bash
# In Ansible, change SSH port to non-standard (e.g., 2222)
# Update UFW rules
# Update deploy.production.yml ssh section
```

### Docker Security
- Keep Docker updated via unattended-upgrades
- Use non-root user in containers (already done in Dockerfile)
- Limit container resources if needed

### Regular Maintenance
```bash
# Weekly: Check disk space
df -h

# Weekly: Check failed login attempts
sudo fail2ban-client status sshd

# Monthly: Review UFW logs
sudo grep UFW /var/log/syslog | tail -50
```

---

## Future: GitHub Actions Automation

Once manual deployment is working, we can add CI/CD:

**Benefits:**
- Auto-deploy on push to main
- Run tests before deployment
- No need to export secrets manually
- Consistent deployment environment

**File:** `.github/workflows/deploy-production.yml`

This will be implemented after successful manual deployment is verified.