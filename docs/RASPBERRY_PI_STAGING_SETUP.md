# Raspberry Pi 5 Staging Server Setup Guide

Complete guide for deploying kw-app staging environment on Raspberry Pi 5 using Docker and Ansible.

## Table of Contents
- [Quick Start - New Raspberry Pi](#quick-start---new-raspberry-pi)
- [Prerequisites](#prerequisites)
- [Raspberry Pi 5 Initial Setup](#raspberry-pi-5-initial-setup)
- [Manual Setup Steps](#manual-setup-steps)
- [Ansible Automation](#ansible-automation)
- [Kamal Deployment (Primary Method)](#kamal-deployment-primary-method)
- [Domain & SSL Setup](#domain--ssl-setup)
- [Alternative: Docker Compose Deployment](#alternative-docker-compose-deployment)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)

---

## Quick Start - New Raspberry Pi

**Complete process to deploy on a brand new Raspberry Pi 5:**

### Step 1: Prepare Raspberry Pi Hardware
```bash
# 1. Flash Ubuntu Server 24.04 LTS (64-bit) to SD card using Raspberry Pi Imager
#    - Download: https://www.raspberrypi.com/software/
#    - Choose OS: Ubuntu Server 24.04 LTS (64-bit)
#    - Configure hostname: pi5main
#    - Enable SSH
#    - Set username: rege
#    - Set password: <your-password>
#    - Configure WiFi (if needed)

# 2. Insert SD card into Raspberry Pi 5
# 3. Power on and wait ~2 minutes for first boot
# 4. Find the IP or use mDNS: pi5main.local
```

### Step 2: Initial Connection and System Prep
```bash
# From your local machine:
# Test connection
ping pi5main.local

# SSH to Raspberry Pi
ssh rege@pi5main.local

# On Raspberry Pi - update system
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y git curl

# Add your SSH public key for passwordless access
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "your-ssh-public-key-here" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Exit and test passwordless SSH
exit
ssh rege@pi5main.local  # Should work without password
```

### Step 3: Clone Ansible Repository
```bash
# On your local machine
cd ~/code  # or wherever you keep projects

# Clone the Ansible infrastructure repository
git clone git@github.com:regedarek/kw-app-ansible.git
cd kw-app-ansible

# Verify structure
ls -la
# Should see: inventory/, playbooks/, roles/, group_vars/, templates/
```

### Step 4: Configure Ansible Vault (First Time Only)
```bash
# If this is your first time, you need the vault password
# Ask team member or check secure password storage

# Test vault access
ansible-vault view group_vars/vault_staging.yml
# Enter vault password when prompted

# Or create .vault_pass file (keep it secure!)
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

### Step 5: Test Ansible Connection
```bash
# From kw-app-ansible directory
ansible staging -m ping

# Expected output:
# raspberry-pi-staging | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### Step 6: Run Initial Setup with Ansible
```bash
# Run the system setup (Docker, firewall, user config)
# This prepares the Pi for Kamal deployments

ansible-playbook playbooks/setup-raspberry-pi.yml --ask-vault-pass --tags system
# Or if using .vault_pass file:
ansible-playbook playbooks/setup-raspberry-pi.yml --vault-password-file .vault_pass --tags system

# This takes ~10-15 minutes
```

### Step 7: Deploy with Kamal
```bash
# From your local machine, in the kw-app directory
cd ~/code/kw-app

# Initial Kamal setup (first time only)
kamal setup -d staging -c config/deploy.staging.yml

# This will:
# - Setup Traefik reverse proxy
# - Deploy PostgreSQL and Redis
# - Build and deploy the application
# - Run database migrations
# - Configure SSL with Let's Encrypt

# Takes ~15-30 minutes depending on internet speed
```

### Step 8: Verify Deployment
```bash
# Check if app is running (after domain setup)
curl https://staging.nowypanel.kw.krakow.pl/up
# Should return: OK

# Check in browser
open https://staging.nowypanel.kw.krakow.pl

# SSH to Pi and check containers
ssh rege@pi5main.local
kamal app details -d staging -c config/deploy.staging.yml

# Or check Docker directly
docker ps

# All containers should be "Up"
```

### Step 9: Setup Automated Backups (Optional but Recommended)
```bash
# SSH to Raspberry Pi
ssh rege@pi5main.local

# Create backup script (already done by Ansible, but verify)
ls -la ~/backup-db.sh

# Setup cron job
crontab -e
# Add this line if not already there:
# 0 2 * * * /home/rege/backup-db.sh

# Test backup manually
./backup-db.sh
ls -la ~/backups/
```

### Redeploy Process (After Initial Setup)

When you need to redeploy the app (new code, updates, etc.):

```bash
# On your local machine - PRIMARY METHOD
cd ~/code/kw-app

# Deploy with Kamal (zero-downtime)
kamal deploy -d staging -c config/deploy.staging.yml

# That's it! Kamal handles:
# - Building the new image
# - Health checks
# - Zero-downtime swap
# - Automatic rollback on failure
```

### Complete Timeline
- **Hardware prep**: 10 minutes
- **System update**: 5-10 minutes
- **Ansible system setup**: 10-15 minutes
- **DNS/Domain setup**: 10 minutes (one-time)
- **Kamal initial deployment**: 15-30 minutes
- **Verification**: 5 minutes
- **Total**: ~60-90 minutes for brand new Raspberry Pi (first time)
- **Subsequent deploys**: ~3-5 minutes with Kamal! 🚀

---

## Prerequisites

### Hardware Requirements
- **Raspberry Pi 5** (8GB RAM recommended for staging)
- **microSD card** (64GB+ recommended) or NVMe SSD
- **Stable network connection** (Ethernet recommended)
- **Power supply** (official 27W USB-C power adapter)

### Software Requirements (on your local machine)
- **Ansible** 2.9+
- **SSH key** for authentication
- **Git** for cloning repository
- **Docker** (for building images)

### Install Ansible locally
```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install ansible

# Verify installation
ansible --version
```

---

## Raspberry Pi 5 Initial Setup

### 1. Install Ubuntu Server 64-bit
Download and flash Ubuntu Server 24.04 LTS (64-bit) for Raspberry Pi:
```bash
# Using Raspberry Pi Imager (recommended)
# Select: Ubuntu Server 24.04 LTS (64-bit)
# Configure WiFi/SSH in advanced options before flashing
```

### 2. Initial SSH Access
```bash
# SSH to Raspberry Pi 5
ssh rege@pi5main.local

# Or using IP address (if .local doesn't resolve)
ssh rege@<raspberry-pi-ip>
```

### 3. Basic System Configuration
```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Set hostname
sudo hostnamectl set-hostname kw-app-staging

# Set timezone
sudo timedatectl set-timezone Europe/Warsaw

# Create deploy user (if not using existing user)
sudo adduser deploy
sudo usermod -aG sudo deploy
sudo usermod -aG docker deploy  # Will be needed after Docker install

# Setup SSH key for deploy user
sudo -u deploy mkdir -p /home/deploy/.ssh
sudo -u deploy touch /home/deploy/.ssh/authorized_keys
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys

# Add your public key
echo "your-ssh-public-key" | sudo tee -a /home/deploy/.ssh/authorized_keys

# Or if using existing rege user
sudo usermod -aG docker rege
```

---

## Manual Setup Steps

If you prefer to setup manually before automating with Ansible:

### 1. Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add deploy user to docker group
sudo usermod -aG docker deploy

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install docker-compose
sudo apt-get install docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

### 2. Install Required System Packages
```bash
sudo apt-get install -y \
  git \
  curl \
  wget \
  build-essential \
  libpq-dev \
  postgresql-client \
  ufw \
  fail2ban \
  htop
```

### 3. Configure Firewall
```bash
# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3002/tcp  # Rails app (staging)
sudo ufw --force enable
sudo ufw status
```

### 4. Setup Application Directory
```bash
# As deploy user
sudo -u deploy mkdir -p /home/deploy/apps/kw-app-staging
sudo chown -R deploy:deploy /home/deploy/apps
```

### 5. Setup Environment Variables
```bash
# Create .env file
sudo -u deploy touch /home/deploy/apps/kw-app-staging/.env.staging

# Add required secrets (edit with your values)
sudo -u deploy tee /home/deploy/apps/kw-app-staging/.env.staging > /dev/null <<EOF
RAILS_ENV=staging
RACK_ENV=staging
SECRET_KEY_BASE=<generate-with-rails-secret>
RAILS_MASTER_KEY=<from-config/master.key>

# Database
DB_HOST=postgres
DB_PORT=5432
POSTGRES_USER=staging_user
POSTGRES_PASSWORD=<secure-password>
POSTGRES_DB=kw_app_staging

# Redis
REDIS_URL_SIDEKIQ=redis://redis:6379/1
REDIS_PASSWORD=<secure-password>

# OpenStack Storage
USE_CLOUD_STORAGE=true
OPENSTACK_TENANT=<your-tenant>
OPENSTACK_USERNAME=<your-username>
OPENSTACK_API_KEY=<your-api-key>

# External Services
STRAVA_CLIENT=<your-client-id>
STRAVA_SECRET=<your-secret>
DOTPAY_PASSWORD=<your-password>
MAILGUN_LOGIN=<your-login>
MAILGUN_PASSWORD=<your-password>
METEOBLUE_KEY=<your-key>
EOF

sudo chmod 600 /home/deploy/apps/kw-app-staging/.env.staging
```

---

## Ansible Automation

### Directory Structure
```
kw-app/
├── ansible/
│   ├── inventory/
│   │   └── staging.yml
│   ├── playbooks/
│   │   ├── setup-raspberry-pi.yml
│   │   ├── deploy-app.yml
│   │   └── maintenance.yml
│   ├── roles/
│   │   ├── common/
│   │   ├── docker/
│   │   ├── security/
│   │   └── kw-app/
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── staging.yml
│   └── ansible.cfg
└── docs/
    └── RASPBERRY_PI_STAGING_SETUP.md
```

### 1. Create Ansible Inventory

**`ansible/inventory/staging.yml`:**
```yaml
all:
  children:
    staging:
      hosts:
        raspberry-pi-staging:
          ansible_host: pi5main.local
          ansible_user: rege
          ansible_python_interpreter: /usr/bin/python3
          
      vars:
        app_name: kw-app
        app_env: staging
        app_directory: /home/rege/apps/kw-app-staging
        docker_compose_version: "2.24.0"
```

### 2a. Create Ansible Repository on GitHub

**Create a separate repository for your infrastructure code:**

```bash
# On your local machine
mkdir kw-app-ansible
cd kw-app-ansible

# Initialize git repository
git init

# Create directory structure
mkdir -p {inventory,playbooks,roles,group_vars,templates}

# Copy the Ansible files from kw-app/ansible/ to this new repo
# (or create them as shown in this guide)

# Create .gitignore
cat > .gitignore << 'EOF'
# Ansible
*.retry
.vault_pass
*.pyc
__pycache__/

# Secrets (DO NOT COMMIT)
group_vars/vault_staging.yml
*.pem
*.key

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF

# Create README
cat > README.md << 'EOF'
# kw-app Ansible Infrastructure

Ansible playbooks for deploying kw-app to Raspberry Pi 5 staging server.

## Prerequisites
- Ansible 2.9+
- SSH access to Raspberry Pi 5 (`rege@pi5main.local`)
- Ansible Vault password

## Quick Start
```bash
# Test connection
ansible staging -m ping

# Deploy staging environment
ansible-playbook playbooks/setup-raspberry-pi.yml --ask-vault-pass

# Quick redeploy
ansible-playbook playbooks/deploy-app.yml --ask-vault-pass
```

## Documentation
See [kw-app/docs/RASPBERRY_PI_STAGING_SETUP.md](https://github.com/regedarek/kw-app/blob/main/docs/RASPBERRY_PI_STAGING_SETUP.md)
EOF

# Initial commit
git add .
git commit -m "Initial Ansible infrastructure for kw-app staging"

# Create repository on GitHub
# Go to: https://github.com/new
# Repository name: kw-app-ansible
# Description: Ansible playbooks for kw-app Raspberry Pi staging deployment
# Private: Yes (recommended for infrastructure code)

# Add remote and push
git remote add origin git@github.com:regedarek/kw-app-ansible.git
git branch -M main
git push -u origin main
```

**Important Security Notes:**
- ✅ **DO commit**: Playbooks, roles, inventory structure, templates
- ❌ **DO NOT commit**: Vault files, SSH keys, `.vault_pass`, actual secrets
- Use Ansible Vault for all sensitive data
- Keep vault password secure (password manager, not in git)
```

### 3. Create Ansible Configuration

**`ansible/ansible.cfg`:**
```ini
[defaults]
inventory = inventory/staging.yml
host_key_checking = False
retry_files_enabled = False
roles_path = roles
interpreter_python = auto_silent

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

### 4. Create Main Playbook

**`ansible/playbooks/setup-raspberry-pi.yml`:**
```yaml
---
- name: Setup Raspberry Pi 5 for kw-app Staging
  hosts: staging
  become: yes
  
  vars:
    deploy_user: rege
    app_directory: /home/rege/apps/kw-app-staging
    
  tasks:
    - name: Update APT cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Upgrade all packages
      apt:
        upgrade: dist
        autoremove: yes
    
    - name: Install required system packages
      apt:
        name:
          - git
          - curl
          - wget
          - build-essential
          - libpq-dev
          - postgresql-client
          - python3-pip
          - ufw
          - fail2ban
          - htop
          - vim
          - ca-certificates
          - gnupg
          - lsb-release
        state: present
    
    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present
    
    - name: Add Docker repository
      apt_repository:
        repo: "deb [arch=arm64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present
    
    - name: Install Docker
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: present
        update_cache: yes
    
    - name: Start and enable Docker service
      systemd:
        name: docker
        state: started
        enabled: yes
    
    - name: Add deploy user to docker group
      user:
        name: "{{ deploy_user }}"
        groups: docker
        append: yes
    
    - name: Configure UFW defaults
      ufw:
        direction: "{{ item.direction }}"
        policy: "{{ item.policy }}"
      loop:
        - { direction: 'incoming', policy: 'deny' }
        - { direction: 'outgoing', policy: 'allow' }
    
    - name: Configure UFW rules
      ufw:
        rule: allow
        port: "{{ item }}"
      loop:
        - '22'    # SSH
        - '80'    # HTTP
        - '443'   # HTTPS
        - '3002'  # Rails staging
    
    - name: Enable UFW
      ufw:
        state: enabled
    
    - name: Create app directory
      file:
        path: "{{ app_directory }}"
        state: directory
        owner: "{{ deploy_user }}"
        group: "{{ deploy_user }}"
        mode: '0755'
    
    - name: Install Docker SDK for Python
      pip:
        name: docker
        state: present
    
    - name: Configure system limits for containers
      sysctl:
        name: "{{ item.key }}"
        value: "{{ item.value }}"
        state: present
        reload: yes
      loop:
        - { key: 'vm.overcommit_memory', value: '1' }
        - { key: 'net.core.somaxconn', value: '4096' }

- name: Deploy kw-app staging
  hosts: staging
  become: yes
  become_user: deploy
  
  vars:
    app_directory: /home/rege/apps/kw-app-staging
    
  tasks:
    - name: Clone or update repository
      git:
        repo: https://github.com/regedarek/kw-app.git
        dest: "{{ app_directory }}"
        version: main
        force: yes
      
    - name: Copy staging docker-compose configuration
      template:
        src: ../templates/docker-compose.staging.yml.j2
        dest: "{{ app_directory }}/docker-compose.staging.yml"
        mode: '0644'
    
    - name: Copy environment file
      template:
        src: ../templates/env.staging.j2
        dest: "{{ app_directory }}/.env.staging"
        mode: '0600'
    
    - name: Pull Docker images
      community.docker.docker_compose:
        project_src: "{{ app_directory }}"
        files: docker-compose.staging.yml
        pull: yes
      environment:
        COMPOSE_FILE: docker-compose.staging.yml
    
    - name: Start Docker containers
      community.docker.docker_compose:
        project_src: "{{ app_directory }}"
        files: docker-compose.staging.yml
        state: present
      environment:
        COMPOSE_FILE: docker-compose.staging.yml
    
    - name: Wait for PostgreSQL to be ready
      wait_for:
        timeout: 30
    
    - name: Create database
      shell: |
        docker compose -f docker-compose.staging.yml exec -T postgres \
          psql -U staging_user -c "CREATE DATABASE IF NOT EXISTS kw_app_staging;" postgres
      args:
        chdir: "{{ app_directory }}"
      ignore_errors: yes
    
    - name: Run database migrations
      shell: |
        docker compose -f docker-compose.staging.yml exec -T app \
          bundle exec rake db:migrate
      args:
        chdir: "{{ app_directory }}"
    
    - name: Seed database (optional)
      shell: |
        docker compose -f docker-compose.staging.yml exec -T app \
          bundle exec rake db:seed
      args:
        chdir: "{{ app_directory }}"
      when: seed_database | default(false)
```

### 5. Create Docker Compose Template for Staging

**`ansible/templates/docker-compose.staging.yml.j2`:**
```yaml
services:
  app:
    image: regedarek/kw-app:staging
    command: ./bin/thrust ./bin/rails server -p 3002 -b 0.0.0.0
    environment:
      - RAILS_ENV=staging
      - DB_HOST=postgres
      - PGUSER={{ postgres_user }}
      - DB_PASSWORD={{ postgres_password }}
      - DB_USER={{ postgres_user }}
      - DB_USERNAME={{ postgres_user }}
      - REDIS_URL_SIDEKIQ=redis://redis:6379/1
      - SECRET_KEY_BASE={{ secret_key_base }}
      - USE_CLOUD_STORAGE=true
    env_file:
      - .env.staging
    volumes:
      - app-storage:/rails/storage
      - app-tmp:/rails/tmp
    ports:
      - "3002:3002"
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    networks:
      - kw-app-staging

  postgres:
    image: postgres:16.0
    environment:
      - POSTGRES_USER={{ postgres_user }}
      - POSTGRES_PASSWORD={{ postgres_password }}
      - POSTGRES_DB=kw_app_staging
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"
    restart: unless-stopped
    networks:
      - kw-app-staging

  sidekiq:
    image: regedarek/kw-app:staging
    command: ./bin/sidekiq -C config/sidekiq.yml
    environment:
      - RAILS_ENV=staging
      - DB_HOST=postgres
      - PGUSER={{ postgres_user }}
      - DB_PASSWORD={{ postgres_password }}
      - DB_USER={{ postgres_user }}
      - DB_USERNAME={{ postgres_user }}
      - REDIS_URL_SIDEKIQ=redis://redis:6379/1
    env_file:
      - .env.staging
    volumes:
      - app-storage:/rails/storage
      - app-tmp:/rails/tmp
    depends_on:
      - postgres
      - redis
    restart: unless-stopped
    networks:
      - kw-app-staging

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass {{ redis_password }}
    volumes:
      - redis-data:/var/lib/redis/data
    restart: unless-stopped
    networks:
      - kw-app-staging

volumes:
  postgres-data:
  redis-data:
  app-storage:
  app-tmp:

networks:
  kw-app-staging:
    name: kw-app-staging
```

### 6. Create Environment Template

**`ansible/templates/env.staging.j2`:**
```bash
RAILS_ENV=staging
RACK_ENV=staging
SECRET_KEY_BASE={{ secret_key_base }}
RAILS_MASTER_KEY={{ rails_master_key }}

# Database
DB_HOST=postgres
DB_PORT=5432
POSTGRES_USER={{ postgres_user }}
POSTGRES_PASSWORD={{ postgres_password }}
POSTGRES_DB=kw_app_staging

# Redis
REDIS_URL_SIDEKIQ=redis://redis:6379/1
REDIS_PASSWORD={{ redis_password }}

# OpenStack
USE_CLOUD_STORAGE={{ use_cloud_storage | default('true') }}
OPENSTACK_TENANT={{ openstack_tenant }}
OPENSTACK_USERNAME={{ openstack_username }}
OPENSTACK_API_KEY={{ openstack_api_key }}

# External Services
STRAVA_CLIENT={{ strava_client }}
STRAVA_SECRET={{ strava_secret }}
DOTPAY_PASSWORD={{ dotpay_password }}
MAILGUN_LOGIN={{ mailgun_login }}
MAILGUN_PASSWORD={{ mailgun_password }}
METEOBLUE_KEY={{ meteoblue_key }}
```

### 7. Create Variables File

**`ansible/group_vars/staging.yml`:**
```yaml
---
# PostgreSQL
postgres_user: staging_user
postgres_password: "{{ vault_postgres_password }}"
postgres_db: kw_app_staging

# Redis
redis_password: "{{ vault_redis_password }}"

# Rails
secret_key_base: "{{ vault_secret_key_base }}"
rails_master_key: "{{ vault_rails_master_key }}"

# OpenStack
use_cloud_storage: true
openstack_tenant: "{{ vault_openstack_tenant }}"
openstack_username: "{{ vault_openstack_username }}"
openstack_api_key: "{{ vault_openstack_api_key }}"

# External services
strava_client: "{{ vault_strava_client }}"
strava_secret: "{{ vault_strava_secret }}"
dotpay_password: "{{ vault_dotpay_password }}"
mailgun_login: "{{ vault_mailgun_login }}"
mailgun_password: "{{ vault_mailgun_password }}"
meteoblue_key: "{{ vault_meteoblue_key }}"
```

### 8. Create Ansible Vault for Secrets

```bash
# Create encrypted vault file
cd ansible
ansible-vault create group_vars/vault_staging.yml

# Add your secrets (will open editor)
---
vault_postgres_password: "your-secure-password"
vault_redis_password: "your-secure-password"
vault_secret_key_base: "generate-with-rails-secret"
vault_rails_master_key: "from-config-master-key"
vault_openstack_tenant: "your-tenant"
vault_openstack_username: "your-username"
vault_openstack_api_key: "your-api-key"
vault_strava_client: "your-client"
vault_strava_secret: "your-secret"
vault_dotpay_password: "your-password"
vault_mailgun_login: "your-login"
vault_mailgun_password: "your-password"
vault_meteoblue_key: "your-key"
```

### 9. Running the Ansible Playbook

```bash
# From project root
cd ansible

# Test connectivity
ansible staging -m ping

# Run setup playbook (will ask for vault password)
ansible-playbook playbooks/setup-raspberry-pi.yml --ask-vault-pass

# Or save vault password to file (secure it!)
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
ansible-playbook playbooks/setup-raspberry-pi.yml --vault-password-file .vault_pass

# Deploy only (skip system setup)
ansible-playbook playbooks/setup-raspberry-pi.yml --ask-vault-pass --tags deploy

# Run with verbose output
ansible-playbook playbooks/setup-raspberry-pi.yml --ask-vault-pass -vv
```

---

## Alternative: Docker Compose Deployment

**Note**: Kamal is the recommended method. Use Docker Compose only if you need direct container access for debugging.

### Using Docker Compose Manually
```bash
# SSH to Raspberry Pi
ssh rege@pi5main.local

# Navigate to app directory
cd /home/rege/apps/kw-app-staging

# Pull latest changes
git pull origin main

# Rebuild and restart containers (with downtime)
docker compose -f docker-compose.staging.yml down
docker compose -f docker-compose.staging.yml build
docker compose -f docker-compose.staging.yml up -d

# Run migrations
docker compose -f docker-compose.staging.yml exec -T app bundle exec rake db:migrate

# Check logs
docker compose -f docker-compose.staging.yml logs -f app
```

**Downsides**: 
- ❌ Has downtime during deployment
- ❌ No automatic rollback
- ❌ Manual health checks
- ❌ Slower process

**Use Kamal instead for staging deployments!**

---

## Kamal Deployment (Primary Method)

### Overview
**Kamal is the recommended deployment method for staging** because it provides:
- ✅ Zero-downtime deployments
- ✅ Automatic health checks
- ✅ Instant rollbacks
- ✅ Built-in SSL with Traefik
- ✅ Same workflow as production
- ✅ Deployment takes only 3-5 minutes!

### Prerequisites
```bash
# Install Kamal on your local machine
gem install kamal

# Verify installation
kamal version
```

### Create Staging Kamal Configuration

**`config/deploy.staging.yml`:**
```yaml
service: kw-app-staging
image: regedarek/kw-app

builder:
  dockerfile: Dockerfile.production
  arch: arm64  # Important for Raspberry Pi!
  
servers:
  web:
    hosts:
      - pi5main.local
    labels:
      traefik.http.routers.kw-app-staging.rule: Host(`staging.nowypanel.kw.krakow.pl`)
    options:
      network: "private"

proxy:
  ssl: true
  app_port: 3000
  host: staging.nowypanel.kw.krakow.pl
  healthcheck:
    path: /up
    interval: 10
    timeout: 5

registry:
  username:
    - KAMAL_REGISTRY_USERNAME
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_ENV: staging
    RACK_ENV: staging
    DB_HOST: kw-app-staging-postgres
    DB_PORT: 5432
  secret:
    - KAMAL_REGISTRY_USERNAME
    - KAMAL_REGISTRY_PASSWORD
    - SECRET_KEY_BASE
    - RAILS_MASTER_KEY
    - POSTGRES_USER
    - POSTGRES_PASSWORD
    - POSTGRES_DB
    - REDIS_URL_SIDEKIQ
    - STRAVA_CLIENT
    - STRAVA_SECRET
    - DOTPAY_PASSWORD
    - MAILGUN_LOGIN
    - MAILGUN_PASSWORD
    - OPENSTACK_TENANT
    - OPENSTACK_USERNAME
    - OPENSTACK_API_KEY
    - METEOBLUE_KEY

ssh:
  user: rege

accessories:
  postgres:
    image: postgres:16.0
    host: pi5main.local
    port: "127.0.0.1:5432:5432"
    env:
      clear:
        POSTGRES_USER: "${POSTGRES_USER}"
        POSTGRES_DB: "${POSTGRES_DB}"
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data
    options:
      network: "private"
  
  redis:
    image: redis:7-alpine
    host: pi5main.local
    port: "127.0.0.1:6379:6379"
    cmd: redis-server --requirepass ${REDIS_PASSWORD}
    directories:
      - data:/data
    options:
      network: "private"
```

### Setup Environment Variables for Kamal

**`.kamal/secrets.staging`:**
```bash
# Docker Registry
KAMAL_REGISTRY_USERNAME=<your-dockerhub-username>
KAMAL_REGISTRY_PASSWORD=<your-dockerhub-token>

# Rails
RAILS_ENV=staging
SECRET_KEY_BASE=<generate-with-rails-secret>
RAILS_MASTER_KEY=<from-config/master.key>

# Database
POSTGRES_USER=staging_user
POSTGRES_PASSWORD=<secure-password>
POSTGRES_DB=kw_app_staging

# Redis
REDIS_PASSWORD=<secure-password>
REDIS_URL_SIDEKIQ=redis://:${REDIS_PASSWORD}@redis:6379/1

# OpenStack
OPENSTACK_TENANT=<your-tenant>
OPENSTACK_USERNAME=<your-username>
OPENSTACK_API_KEY=<your-api-key>

# External Services
STRAVA_CLIENT=<your-client>
STRAVA_SECRET=<your-secret>
DOTPAY_PASSWORD=<your-password>
MAILGUN_LOGIN=<your-login>
MAILGUN_PASSWORD=<your-password>
METEOBLUE_KEY=<your-key>
```

**Important**: Add `.kamal/secrets*` to your `.gitignore`!

### Kamal Deployment Commands

```bash
# Initial setup (first time only)
kamal setup -d staging -c config/deploy.staging.yml

# Deploy application
kamal deploy -d staging -c config/deploy.staging.yml

# Deploy with specific tag/version
kamal deploy -d staging -c config/deploy.staging.yml --version=v1.2.3

# View logs
kamal app logs -d staging -c config/deploy.staging.yml

# Follow logs
kamal app logs -f -d staging -c config/deploy.staging.yml

# Run Rails console
kamal app exec -d staging -c config/deploy.staging.yml -i 'bundle exec rails console'

# Run migrations
kamal app exec -d staging -c config/deploy.staging.yml 'bundle exec rake db:migrate'

# Restart application
kamal app restart -d staging -c config/deploy.staging.yml

# Check status
kamal app details -d staging -c config/deploy.staging.yml

# SSH to server
kamal app exec -d staging -c config/deploy.staging.yml --reuse bash

# Rollback to previous version
kamal rollback -d staging -c config/deploy.staging.yml
```

### Build for ARM64 Architecture

**Important**: Raspberry Pi 5 uses ARM64 architecture. You need to build multi-platform images.

```bash
# Setup Docker buildx for multi-platform builds
docker buildx create --name multiplatform --driver docker-container --use
docker buildx inspect --bootstrap

# Build and push ARM64 image
docker buildx build \
  --platform linux/arm64 \
  -f Dockerfile.production \
  -t regedarek/kw-app:staging-arm64 \
  --push \
  .

# Or let Kamal handle it (configured in deploy.staging.yml with arch: arm64)
kamal build push -d staging -c config/deploy.staging.yml
```

### Why Kamal for Staging?

**Kamal Benefits:**
- ✅ **Zero-downtime**: Users never see downtime during deploys
- ✅ **Fast deploys**: 3-5 minutes for subsequent deploys
- ✅ **Safety**: Automatic rollback if health checks fail
- ✅ **Production-like**: Same deployment process as production
- ✅ **Built-in SSL**: Traefik handles Let's Encrypt automatically
- ✅ **Simple**: One command to deploy: `kamal deploy`

**Docker Compose is for local development only.**

### Ansible Playbook for Kamal Setup

**`ansible/playbooks/setup-kamal.yml`:**
```yaml
---
- name: Prepare Raspberry Pi for Kamal Deployments
  hosts: staging
  become: yes
  
  vars:
    deploy_user: rege
    
  tasks:
    - name: Ensure Docker is installed
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present
    
    - name: Add user to docker group
      user:
        name: "{{ deploy_user }}"
        groups: docker
        append: yes
    
    - name: Create Kamal directories
      file:
        path: "{{ item }}"
        state: directory
        owner: "{{ deploy_user }}"
        group: "{{ deploy_user }}"
        mode: '0755'
      loop:
        - /home/{{ deploy_user }}/.kamal
        - /home/{{ deploy_user }}/kw-app-staging-data
    
    - name: Create Docker network for Kamal
      community.docker.docker_network:
        name: private
        state: present
    
    - name: Install Traefik for reverse proxy
      community.docker.docker_container:
        name: traefik
        image: traefik:v2.10
        state: started
        restart_policy: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - /home/{{ deploy_user }}/traefik:/etc/traefik
          - /home/{{ deploy_user }}/traefik/acme.json:/acme.json
        command:
          - "--api.insecure=true"
          - "--providers.docker=true"
          - "--providers.docker.exposedbydefault=false"
          - "--entrypoints.web.address=:80"
          - "--entrypoints.websecure.address=:443"
          - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
          - "--certificatesresolvers.letsencrypt.acme.email=your-email@example.com"
          - "--certificatesresolvers.letsencrypt.acme.storage=/acme.json"
        networks:
          - name: private
```

**Run Kamal setup:**
```bash
cd kw-app-ansible
ansible-playbook playbooks/setup-kamal.yml --ask-vault-pass
```

---

## Domain & SSL Setup

### Overview
Setup `staging.nowypanel.kw.krakow.pl` to point to your Raspberry Pi with automatic SSL certificates.

### Step 1: Configure DNS on OVH

**Add subdomain DNS record:**

1. Login to OVH: https://www.ovh.com/manager/
2. Go to: Web Cloud → Domain names → `kw.krakow.pl`
3. Click on "DNS Zone" tab
4. Click "Add an entry"
5. Add A record:
   - **Subdomain**: `staging.nowypanel` (or `pi5main.nowypanel`)
   - **Type**: A
   - **Target/Value**: `<your-public-ip>` (your home/office IP where Raspberry Pi is)
   - **TTL**: 3600 (1 hour)

**Find your public IP:**
```bash
# From your local network where Raspberry Pi is:
curl ifconfig.me
# or
curl icanhazip.com
```

**Example DNS record:**
```
staging.nowypanel.kw.krakow.pl  A  1.2.3.4
```

### Step 2: Configure Router Port Forwarding

**Forward ports 80 and 443 to Raspberry Pi:**

1. Login to your router admin panel (usually 192.168.1.1 or 192.168.0.1)
2. Find "Port Forwarding" or "NAT" settings
3. Add two rules:

```
Service: HTTP
External Port: 80
Internal IP: <raspberry-pi-local-ip> (e.g., 192.168.1.100)
Internal Port: 80
Protocol: TCP

Service: HTTPS
External Port: 443
Internal IP: <raspberry-pi-local-ip>
Internal Port: 443
Protocol: TCP
```

**Find Raspberry Pi local IP:**
```bash
ssh rege@pi5main.local
hostname -I
# Example output: 192.168.1.100
```

### Step 3: Setup Reverse Proxy with Traefik

**Option A: Using Traefik (Recommended with Kamal)**

Traefik provides automatic SSL via Let's Encrypt and works seamlessly with Kamal.

**Create Traefik configuration:**
```bash
ssh rege@pi5main.local

# Create directories
mkdir -p ~/traefik
cd ~/traefik

# Create traefik.yml
cat > traefik.yml << 'EOF'
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false
    network: private

certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@example.com
      storage: /acme.json
      tlsChallenge: {}
EOF

# Create acme.json for SSL certificates
touch acme.json
chmod 600 acme.json

# Create docker-compose for Traefik
cat > docker-compose.traefik.yml << 'EOF'
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Traefik dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/etc/traefik/traefik.yml:ro
      - ./acme.json:/acme.json
    networks:
      - private

networks:
  private:
    external: true
EOF

# Start Traefik
docker compose -f docker-compose.traefik.yml up -d

# Verify Traefik is running
docker ps | grep traefik
```

**Access Traefik dashboard**: `http://pi5main.local:8080`

**Option B: Using Caddy (Simpler Alternative)**

```bash
ssh rege@pi5main.local

mkdir -p ~/caddy
cat > ~/caddy/Caddyfile << 'EOF'
staging.nowypanel.kw.krakow.pl {
    reverse_proxy localhost:3002
    
    encode gzip
    
    log {
        output file /var/log/caddy/access.log
        format json
    }
}
EOF

cat > ~/caddy/docker-compose.yml << 'EOF'
services:
  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
      - caddy-config:/config

volumes:
  caddy-data:
  caddy-config:
EOF

cd ~/caddy
docker compose up -d
```

Caddy automatically handles SSL certificates from Let's Encrypt!

### Step 4: Update Firewall Rules

```bash
ssh rege@pi5main.local

# Allow HTTP and HTTPS through firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
sudo ufw status
```

### Step 5: Test SSL Setup

```bash
# Test DNS resolution (from your local machine)
nslookup staging.nowypanel.kw.krakow.pl
# Should return your public IP

# Test HTTP (should redirect to HTTPS)
curl -I http://staging.nowypanel.kw.krakow.pl

# Test HTTPS
curl -I https://staging.nowypanel.kw.krakow.pl/up
# Should return: HTTP/2 200

# Test in browser
open https://staging.nowypanel.kw.krakow.pl
```

### Step 6: Update Kamal Configuration for Domain

Update `config/deploy.staging.yml`:
```yaml
proxy:
  ssl: true
  app_port: 3000
  host: staging.nowypanel.kw.krakow.pl
  healthcheck:
    path: /up
    interval: 10
    timeout: 5
```

### Alternative: Dynamic DNS (if no static IP)

If your home IP changes frequently:

**Option 1: Use DynDNS service on OVH**
```bash
# Install ddclient on Raspberry Pi
ssh rege@pi5main.local
sudo apt-get install ddclient

# Configure for OVH DynDNS
sudo nano /etc/ddclient.conf
# Add OVH configuration (check OVH docs for specific settings)
```

**Option 2: Use Cloudflare Tunnel (No port forwarding needed!)**
```bash
# Install cloudflared on Raspberry Pi
ssh rege@pi5main.local
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared-linux-arm64.deb

# Login and setup tunnel
cloudflared tunnel login
cloudflared tunnel create kw-app-staging
cloudflared tunnel route dns kw-app-staging staging.nowypanel.kw.krakow.pl

# Create config
mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml << 'EOF'
tunnel: <your-tunnel-id>
credentials-file: /home/rege/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: staging.nowypanel.kw.krakow.pl
    service: http://localhost:3002
  - service: http_status:404
EOF

# Run as service
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

### SSL Certificate Renewal

**Let's Encrypt certificates auto-renew with Traefik/Caddy**, but verify:

```bash
# Check certificate expiry
echo | openssl s_client -servername staging.nowypanel.kw.krakow.pl -connect staging.nowypanel.kw.krakow.pl:443 2>/dev/null | openssl x509 -noout -dates

# Traefik auto-renews at 30 days before expiry
# Caddy auto-renews at 30 days before expiry
# No action needed!
```

### Domain Setup Checklist

- [ ] DNS A record created on OVH
- [ ] DNS propagated (check with `nslookup`)
- [ ] Router port forwarding configured (80, 443)
- [ ] Traefik/Caddy running on Raspberry Pi
- [ ] Firewall allows ports 80, 443
- [ ] SSL certificate obtained (check in browser)
- [ ] App accessible via HTTPS
- [ ] Kamal deploy.staging.yml updated with domain

### Troubleshooting Domain/SSL Issues

```bash
# DNS not resolving
dig staging.nowypanel.kw.krakow.pl
nslookup staging.nowypanel.kw.krakow.pl

# Check if port 80/443 are open from outside
# Use: https://www.yougetsignal.com/tools/open-ports/
# Or: telnet your-public-ip 80

# Check Traefik logs
docker logs traefik

# Check SSL certificate
curl -vI https://staging.nowypanel.kw.krakow.pl

# Test local access (bypass DNS)
curl -H "Host: staging.nowypanel.kw.krakow.pl" http://localhost
```

---

## Monitoring & Maintenance

### Overview
Proper monitoring ensures your staging server runs smoothly and alerts you to issues before they become critical.

### Quick Health Checks
```bash
# Check all containers
docker compose -f docker-compose.staging.yml ps

# Check app health endpoint
curl http://pi5main.local:3002/up

# Check logs
docker compose -f docker-compose.staging.yml logs -f app
docker compose -f docker-compose.staging.yml logs -f sidekiq

# Check resource usage
docker stats

# System resources
htop
df -h
free -m
```

### Monitoring Stack Setup

#### Option 1: Simple Monitoring (Recommended for Staging)

**Install basic monitoring tools:**
```bash
# SSH to Raspberry Pi
ssh rege@pi5main.local

# Install monitoring tools
sudo apt-get update
sudo apt-get install -y htop iotop nethogs glances

# Install ctop (Docker container monitor)
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-arm64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# Use glances (all-in-one monitoring)
glances
# Press 'h' for help, 'q' to quit
```

**Create monitoring dashboard script:**
```bash
cat > ~/monitor.sh << 'EOF'
#!/bin/bash
clear
echo "=== KW-APP STAGING MONITOR ==="
echo "Server: pi5main.local"
echo "Time: $(date)"
echo ""

echo "=== SYSTEM ==="
echo "Uptime: $(uptime -p)"
echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "CPU Temp: $(vcgencmd measure_temp)"
echo "Throttled: $(vcgencmd get_throttled)"
echo ""

echo "=== MEMORY ==="
free -h | grep -E 'Mem|Swap'
echo ""

echo "=== DISK ==="
df -h / | tail -1
df -h /home | tail -1
echo ""

echo "=== DOCKER CONTAINERS ==="
cd ~/apps/kw-app-staging
docker compose -f docker-compose.staging.yml ps
echo ""

echo "=== DOCKER STATS (5 sec snapshot) ==="
timeout 5 docker stats --no-stream
EOF

chmod +x ~/monitor.sh

# Run monitor
./monitor.sh
```

#### Option 2: Advanced Monitoring (Prometheus + Grafana)

**Add monitoring stack to docker-compose:**
```yaml
# Add to docker-compose.staging.yml

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - "9090:9090"
    restart: unless-stopped
    networks:
      - kw-app-staging

  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3003:3000"
    restart: unless-stopped
    networks:
      - kw-app-staging
    depends_on:
      - prometheus

  node-exporter:
    image: prom/node-exporter:latest
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    restart: unless-stopped
    networks:
      - kw-app-staging

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"
    restart: unless-stopped
    networks:
      - kw-app-staging
```

**Create Prometheus config:**
```bash
mkdir -p ~/apps/kw-app-staging/monitoring

cat > ~/apps/kw-app-staging/monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
EOF
```

**Access monitoring dashboards:**
- Grafana: `http://pi5main.local:3003` (admin/admin)
- Prometheus: `http://pi5main.local:9090`
- cAdvisor: `http://pi5main.local:8080`

### Log Management

**Centralized logging with dedicated log viewer:**
```bash
# View all logs in real-time
docker compose -f docker-compose.staging.yml logs -f

# View specific service
docker compose -f docker-compose.staging.yml logs -f app

# Search logs
docker compose -f docker-compose.staging.yml logs app | grep ERROR

# Last 100 lines
docker compose -f docker-compose.staging.yml logs --tail=100 app

# Since specific time
docker compose -f docker-compose.staging.yml logs --since 2024-01-01T10:00:00 app
```

**Setup log rotation:**
```bash
# Configure Docker log rotation
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker
```

**Create log analysis script:**
```bash
cat > ~/analyze-logs.sh << 'EOF'
#!/bin/bash
cd ~/apps/kw-app-staging

echo "=== ERROR SUMMARY (Last 24h) ==="
docker compose -f docker-compose.staging.yml logs --since 24h | grep -i error | wc -l
echo "errors found"
echo ""

echo "=== TOP 10 ERRORS ==="
docker compose -f docker-compose.staging.yml logs --since 24h | grep -i error | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== WARNING SUMMARY ==="
docker compose -f docker-compose.staging.yml logs --since 24h | grep -i warn | wc -l
echo "warnings found"
echo ""

echo "=== RECENT FAILURES ==="
docker compose -f docker-compose.staging.yml logs --since 1h | grep -iE "fail|fatal|exception" | tail -20
EOF

chmod +x ~/analyze-logs.sh
```

### Performance Monitoring

**Monitor Raspberry Pi specific metrics:**
```bash
# CPU Temperature (important for throttling)
watch -n 2 vcgencmd measure_temp

# Check for throttling
vcgencmd get_throttled
# 0x0 = OK
# Non-zero = throttling occurred

# CPU frequency
vcgencmd measure_clock arm

# Memory split
vcgencmd get_mem arm
vcgencmd get_mem gpu

# Detailed system info
vcgencmd measure_volts
vcgencmd measure_clock arm
```

**Application performance:**
```bash
# Rails request times (from logs)
docker compose -f docker-compose.staging.yml logs app | grep "Completed" | tail -20

# Database query performance
docker compose -f docker-compose.staging.yml exec postgres psql -U staging_user -d kw_app_staging -c "
  SELECT query, calls, total_time, mean_time 
  FROM pg_stat_statements 
  ORDER BY mean_time DESC 
  LIMIT 10;"

# Sidekiq queue status
docker compose -f docker-compose.staging.yml exec app bundle exec rails runner "
  require 'sidekiq/api'
  stats = Sidekiq::Stats.new
  puts \"Processed: #{stats.processed}\"
  puts \"Failed: #{stats.failed}\"
  puts \"Queued: #{stats.enqueued}\"
"
```

### Alerts & Notifications

**Setup simple email alerts (using existing Mailgun):**
```bash
cat > ~/check-health.sh << 'EOF'
#!/bin/bash
# Health check script that sends email on failure

APP_URL="http://pi5main.local:3002/up"
ADMIN_EMAIL="your-email@example.com"

# Check if app responds
if ! curl -f -s --max-time 10 "$APP_URL" > /dev/null; then
    # App is down, send alert
    MESSAGE="KW-APP staging server is DOWN at $(date)"
    
    # Log to syslog
    logger -t kw-app-monitor "$MESSAGE"
    
    # Send email via Mailgun (configure with your credentials)
    curl -s --user "api:YOUR_MAILGUN_API_KEY" \
        https://api.mailgun.net/v3/YOUR_DOMAIN/messages \
        -F from="monitoring@your-domain.com" \
        -F to="$ADMIN_EMAIL" \
        -F subject="ALERT: KW-APP Staging Down" \
        -F text="$MESSAGE"
    
    exit 1
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    MESSAGE="WARNING: Disk usage at ${DISK_USAGE}%"
    logger -t kw-app-monitor "$MESSAGE"
    # Send email...
fi

# Check CPU temp
TEMP=$(vcgencmd measure_temp | grep -o '[0-9.]*')
if [ "${TEMP%.*}" -gt 75 ]; then
    MESSAGE="WARNING: CPU temperature at ${TEMP}°C"
    logger -t kw-app-monitor "$MESSAGE"
    # Send email...
fi
EOF

chmod +x ~/check-health.sh

# Add to crontab (check every 5 minutes)
crontab -e
# Add: */5 * * * * /home/rege/check-health.sh
```

### Monitoring Checklist

**Daily:**
- [ ] Check app is accessible: `curl http://pi5main.local:3002/up`
- [ ] Review error logs: `~/analyze-logs.sh`
- [ ] Check container status: `docker compose ps`

**Weekly:**
- [ ] Review disk usage: `df -h`
- [ ] Check memory usage: `free -h`
- [ ] Review database size: `docker compose exec postgres psql -U staging_user -d kw_app_staging -c "\l+"`
- [ ] Verify backups exist: `ls -lh ~/backups/`

**Monthly:**
- [ ] System updates: `sudo apt-get update && sudo apt-get upgrade`
- [ ] Clean old Docker images: `docker system prune -a`
- [ ] Review and rotate logs
- [ ] Test backup restoration
- [ ] Review security updates

### Monitoring URLs Reference
- **App**: `http://pi5main.local:3002`
- **Health Check**: `http://pi5main.local:3002/up`
- **Sidekiq Dashboard**: `http://pi5main.local:3002/sidekiq`
- **Grafana** (if enabled): `http://pi5main.local:3003`
- **Prometheus** (if enabled): `http://pi5main.local:9090`
- **cAdvisor** (if enabled): `http://pi5main.local:8080`

### Automated Monitoring Setup with Ansible

**Create monitoring setup playbook:**

**`ansible/playbooks/setup-monitoring.yml`:**
```yaml
---
- name: Setup Monitoring for kw-app Staging
  hosts: staging
  become: yes
  become_user: rege
  
  vars:
    app_directory: /home/rege/apps/kw-app-staging
    
  tasks:
    - name: Install monitoring tools
      become: yes
      become_user: root
      apt:
        name:
          - htop
          - iotop
          - nethogs
          - glances
        state: present
        update_cache: yes
    
    - name: Install ctop (Docker container monitor)
      become: yes
      become_user: root
      get_url:
        url: https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-arm64
        dest: /usr/local/bin/ctop
        mode: '0755'
    
    - name: Create monitoring script
      copy:
        dest: /home/rege/monitor.sh
        mode: '0755'
        content: |
          #!/bin/bash
          clear
          echo "=== KW-APP STAGING MONITOR ==="
          echo "Server: pi5main.local"
          echo "Time: $(date)"
          echo ""
          
          echo "=== SYSTEM ==="
          echo "Uptime: $(uptime -p)"
          echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
          echo "CPU Temp: $(vcgencmd measure_temp)"
          echo "Throttled: $(vcgencmd get_throttled)"
          echo ""
          
          echo "=== MEMORY ==="
          free -h | grep -E 'Mem|Swap'
          echo ""
          
          echo "=== DISK ==="
          df -h / | tail -1
          df -h /home | tail -1
          echo ""
          
          echo "=== DOCKER CONTAINERS ==="
          cd ~/apps/kw-app-staging
          docker compose -f docker-compose.staging.yml ps
          echo ""
          
          echo "=== DOCKER STATS (5 sec snapshot) ==="
          timeout 5 docker stats --no-stream
    
    - name: Create log analysis script
      copy:
        dest: /home/rege/analyze-logs.sh
        mode: '0755'
        content: |
          #!/bin/bash
          cd ~/apps/kw-app-staging
          
          echo "=== ERROR SUMMARY (Last 24h) ==="
          docker compose -f docker-compose.staging.yml logs --since 24h | grep -i error | wc -l
          echo "errors found"
          echo ""
          
          echo "=== TOP 10 ERRORS ==="
          docker compose -f docker-compose.staging.yml logs --since 24h | grep -i error | sort | uniq -c | sort -rn | head -10
          echo ""
          
          echo "=== WARNING SUMMARY ==="
          docker compose -f docker-compose.staging.yml logs --since 24h | grep -i warn | wc -l
          echo "warnings found"
          echo ""
          
          echo "=== RECENT FAILURES ==="
          docker compose -f docker-compose.staging.yml logs --since 1h | grep -iE "fail|fatal|exception" | tail -20
    
    - name: Create health check script
      copy:
        dest: /home/rege/check-health.sh
        mode: '0755'
        content: |
          #!/bin/bash
          APP_URL="http://pi5main.local:3002/up"
          
          # Check if app responds
          if ! curl -f -s --max-time 10 "$APP_URL" > /dev/null; then
              MESSAGE="KW-APP staging server is DOWN at $(date)"
              logger -t kw-app-monitor "$MESSAGE"
              echo "$MESSAGE"
              exit 1
          fi
          
          # Check disk space
          DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
          if [ "$DISK_USAGE" -gt 85 ]; then
              MESSAGE="WARNING: Disk usage at ${DISK_USAGE}%"
              logger -t kw-app-monitor "$MESSAGE"
              echo "$MESSAGE"
          fi
          
          # Check CPU temp
          TEMP=$(vcgencmd measure_temp | grep -o '[0-9.]*')
          if [ "${TEMP%.*}" -gt 75 ]; then
              MESSAGE="WARNING: CPU temperature at ${TEMP}°C"
              logger -t kw-app-monitor "$MESSAGE"
              echo "$MESSAGE"
          fi
          
          echo "Health check passed at $(date)"
    
    - name: Setup health check cron job
      cron:
        name: "KW-APP health check"
        minute: "*/5"
        job: "/home/rege/check-health.sh >> /home/rege/health-check.log 2>&1"
    
    - name: Configure Docker log rotation
      become: yes
      become_user: root
      copy:
        dest: /etc/docker/daemon.json
        content: |
          {
            "log-driver": "json-file",
            "log-opts": {
              "max-size": "10m",
              "max-file": "3"
            }
          }
      notify: Restart Docker
  
  handlers:
    - name: Restart Docker
      become: yes
      become_user: root
      systemd:
        name: docker
        state: restarted
```

**Run monitoring setup:**
```bash
# From your local machine
cd kw-app-ansible
ansible-playbook playbooks/setup-monitoring.yml --ask-vault-pass
```

### Database Backups
```bash
# Create backup script
cat > /home/rege/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=/home/rege/backups
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

docker compose -f /home/rege/apps/kw-app-staging/docker-compose.staging.yml \
  exec -T postgres pg_dump -U staging_user kw_app_staging | \
  gzip > $BACKUP_DIR/kw_app_staging_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "kw_app_staging_*.sql.gz" -mtime +7 -delete
EOF

chmod +x /home/rege/backup-db.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /home/rege/backup-db.sh
```

### Automated Updates (Ansible)
**`ansible/playbooks/maintenance.yml`:**
```yaml
---
- name: Maintenance Tasks
  hosts: staging
  become: yes
  
  tasks:
    - name: Update system packages
      apt:
        update_cache: yes
        upgrade: dist
        autoremove: yes
    
    - name: Clean Docker system
      shell: docker system prune -af --volumes
      become_user: deploy
    
    - name: Restart containers
      community.docker.docker_compose:
        project_src: /home/rege/apps/kw-app-staging
        files: docker-compose.staging.yml
        restarted: yes
      become_user: rege
```

---

## Troubleshooting

### Container Issues
```bash
# Container won't start
docker compose -f docker-compose.staging.yml logs app

# Permission issues
sudo chown -R 1000:1000 /home/rege/apps/kw-app-staging/storage
sudo chown -R 1000:1000 /home/rege/apps/kw-app-staging/tmp

# Out of memory
free -m
docker stats
# Consider adding swap or limiting container memory

# Network issues
docker network ls
docker network inspect kw-app-staging
```

### Database Issues
```bash
# Can't connect to database
docker compose -f docker-compose.staging.yml exec postgres psql -U staging_user -d kw_app_staging

# Reset database
docker compose -f docker-compose.staging.yml exec -T postgres psql -U staging_user -c "DROP DATABASE kw_app_staging;" postgres
docker compose -f docker-compose.staging.yml exec -T postgres psql -U staging_user -c "CREATE DATABASE kw_app_staging;" postgres
docker compose -f docker-compose.staging.yml exec -T app bundle exec rake db:migrate db:seed
```

### Performance Issues
```bash
# Check CPU throttling (Raspberry Pi specific)
vcgencmd measure_temp
vcgencmd get_throttled

# Monitor system
htop
iotop
iostat -x 1

# Check Docker resource usage
docker stats --no-stream
```

### Ansible Issues
```bash
# Test connection
ansible staging -m ping -vv

# Check syntax
ansible-playbook playbooks/setup-raspberry-pi.yml --syntax-check

# Dry run
ansible-playbook playbooks/setup-raspberry-pi.yml --check

# Run specific task
ansible-playbook playbooks/setup-raspberry-pi.yml --start-at-task="Install Docker"
```

---

### Quick Reference

### Essential Commands

**Primary: Kamal Deployment (⭐ Recommended)**
```bash
# Initial setup (first time only)
cd ~/code/kw-app
kamal setup -d staging -c config/deploy.staging.yml

# Deploy (use this for every deployment!)
kamal deploy -d staging -c config/deploy.staging.yml

# View logs
kamal app logs -f -d staging -c config/deploy.staging.yml

# Run Rails console
kamal app exec -d staging -c config/deploy.staging.yml -i 'bundle exec rails console'

# Run migrations
kamal app exec -d staging -c config/deploy.staging.yml 'bundle exec rake db:migrate'

# Rollback (if something goes wrong)
kamal rollback -d staging -c config/deploy.staging.yml

# Check status
kamal app details -d staging -c config/deploy.staging.yml
```

**Infrastructure: Ansible (for system setup)**
```bash
# Initial system setup (first time only)
cd ansible && ansible-playbook playbooks/setup-raspberry-pi.yml --ask-vault-pass --tags system

# Setup monitoring
cd ansible && ansible-playbook playbooks/setup-monitoring.yml --ask-vault-pass
```

**Debugging: Direct Docker (rarely needed)**
```bash
# SSH to server
ssh rege@pi5main.local

# View all containers
docker ps

# View logs directly
docker logs -f kw-app-staging-web-1

# Database backup
./backup-db.sh
```

**Monitoring:**
```bash
# Quick health check
~/monitor.sh

# Analyze logs
~/analyze-logs.sh

# Check container stats
ctop
```

### Useful URLs

**Local Access:**
- **App**: `http://pi5main.local:3002`
- **Health Check**: `http://pi5main.local:3002/up`
- **Sidekiq Dashboard**: `http://pi5main.local:3002/sidekiq`

**Public Access (after domain setup):**
- **App**: `https://staging.nowypanel.kw.krakow.pl`
- **Health Check**: `https://staging.nowypanel.kw.krakow.pl/up`
- **Sidekiq Dashboard**: `https://staging.nowypanel.kw.krakow.pl/sidekiq`

**Monitoring (if enabled):**
- **Grafana**: `http://pi5main.local:3003`
- **Prometheus**: `http://pi5main.local:9090`
- **cAdvisor**: `http://pi5main.local:8080`
- **Traefik Dashboard**: `http://pi5main.local:8080`

### GitHub Repositories
- **Main App**: `https://github.com/regedarek/kw-app`
- **Ansible Infrastructure**: `https://github.com/regedarek/kw-app-ansible` (create as shown above)

### Deployment Strategies Comparison

| Feature | Kamal ⭐ | Ansible | Docker Compose |
|---------|-------|---------|----------------|
| **Best For** | **Staging & Production** | Infrastructure setup | Local dev only |
| **Downtime** | ✅ Zero-downtime | Depends | ❌ Yes |
| **Deploy Speed** | ✅ 3-5 min | 10-15 min | 5-10 min |
| **Rollback** | ✅ Instant | ❌ Manual | ❌ Manual |
| **Health Checks** | ✅ Built-in | ❌ Manual | ❌ Manual |
| **SSL/Domain** | ✅ Automatic (Traefik) | Can automate | ❌ Manual |
| **Safety** | ✅ Auto-rollback on failure | ❌ No | ❌ No |
| **Recommended For Staging?** | **YES! 🎯** | System setup only | No |

**TL;DR**: Use Kamal for all staging deployments!

---

## Security Considerations

1. **Always use Ansible Vault** for sensitive data
2. **Keep SSH keys secure** - never commit to repository
3. **Update regularly**: `ansible-playbook playbooks/maintenance.yml`
4. **Monitor logs** for suspicious activity
5. **Backup regularly** - automate with cron
6. **Use strong passwords** for all services
7. **Limit SSH access** - consider changing default port 22
8. **Enable fail2ban** to prevent brute-force attacks

---

## Additional Resources

- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker on ARM](https://docs.docker.com/desktop/install/linux-install/)
- [Kamal Documentation](https://kamal-deploy.org/)

---

**Last Updated**: 2024
**Maintained By**: kw-app team