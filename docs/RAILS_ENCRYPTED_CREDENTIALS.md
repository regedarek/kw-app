# Rails Encrypted Credentials Migration Plan

## Table of Contents
1. [Current State Analysis](#current-state-analysis)
2. [Target State](#target-state)
3. [Migration Strategy](#migration-strategy)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Deployment to Staging](#deployment-to-staging)
6. [Deployment to Production](#deployment-to-production)
7. [Cleanup](#cleanup)
8. [Rollback Plan](#rollback-plan)

---

## Current State Analysis

### Existing Secrets Management

**Current Approach:**
- ✅ `config/master.key` exists (for default credentials)
- ❌ No environment-specific credentials files
- ✅ Secrets stored in environment variables (ENV)
- ✅ Kamal `deploy.yml` configured with `RAILS_MASTER_KEY` in secret section

**Secrets Currently in ENV Variables (from deploy.yml):**
```yaml
env:
  secret:
    - KAMAL_REGISTRY_USERNAME
    - KAMAL_REGISTRY_PASSWORD
    - RAILS_MASTER_KEY
    - PRODUCTION_DATABASE_NAME
    - PRODUCTION_DATABASE_USERNAME
    - PRODUCTION_DATABASE_PASSWORD
    - PRODUCTION_DATABASE_HOST
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
    - POSTGRES_USER
    - POSTGRES_PASSWORD
```

**ENV Usage in Codebase:**
- `config/database.yml` - Database credentials
- `config/initializers/carrierwave.rb` - OpenStack credentials via `ENV['USE_CLOUD_STORAGE']`
- `config/initializers/sidekiq.rb` - Redis credentials
- `app/models/db/activities/mountain_route.rb` - `ENV['GOOGLE_STATIC_MAPS_API_KEY']`
- `app/uploaders/application_uploader.rb` - `ENV['USE_CLOUD_STORAGE']`

**Files Already Gitignored:**
```
/config/master.key
/config/credentials/production.key
.env
```

---

## Target State

### After Migration

**File Structure:**
```
config/
  credentials.yml.enc              # Default/shared credentials (committed)
  credentials/
    development.yml.enc            # Dev-specific secrets (committed)
    staging.yml.enc                # Staging-specific secrets (committed)
    production.yml.enc             # Production-specific secrets (committed)
  master.key                       # Dev master key (NOT committed)
  credentials/
    development.key                # Dev key (NOT committed, optional)
    staging.key                    # Staging key (NOT committed)
    production.key                 # Production key (NOT committed)
```

**Credentials Structure (YAML - decrypted view):**
```yaml
# config/credentials/production.yml.enc (decrypted)
secret_key_base: <generated>

database:
  name: kw_app_production
  username: <username>
  password: <password>
  host: kw-app-postgres
  port: 5432

redis:
  url: redis://localhost:6379/1
  password: <password>

strava:
  client_id: <id>
  client_secret: <secret>

payment:
  dotpay_password: <password>

mailgun:
  login: <login>
  password: <password>

openstack:
  tenant: <tenant>
  username: <username>
  api_key: <key>

google:
  static_maps_api_key: <key>

meteoblue:
  api_key: <key>
```

**Code Changes Required:**
```ruby
# Before
ENV['MAILGUN_LOGIN']

# After
Rails.application.credentials.mailgun.login
# or
Rails.application.credentials.dig(:mailgun, :login)
```

---

## Migration Strategy

### Principles
1. **Zero Downtime** - No service interruption during migration
2. **Backward Compatible** - Support both ENV and credentials during transition
3. **Environment-by-Environment** - Migrate dev → staging → production
4. **Reversible** - Can rollback at any stage
5. **Secure** - Master keys shared via 1Password, never committed

### Migration Phases

**Phase 1: Setup & Development**
- Create environment-specific credentials
- Migrate code to use credentials (with ENV fallback)
- Test locally

**Phase 2: Staging Deployment**
- Deploy to staging with credentials
- Verify functionality
- Run smoke tests

**Phase 3: Production Deployment**
- Deploy to production with credentials
- Monitor for issues
- Verify all integrations

**Phase 4: Cleanup**
- Remove ENV fallbacks from code
- Remove ENV variables from Kamal config
- Update documentation

---

## Step-by-Step Implementation

### Prerequisites
- [ ] 1Password vault access (for storing master keys)
- [ ] SSH access to staging/production servers
- [ ] Backup of current `.env` file
- [ ] All secrets documented

### Step 1: Backup Current State

```bash
# Backup current .env (if exists)
cp .env .env.backup

# Document all current ENV variables
kamal config | grep -A 50 "env:" > docs/current_env_backup.txt

# Git commit current state
git add -A
git commit -m "Backup: Current state before credentials migration"
```

### Step 2: Create Environment-Specific Credentials

```bash
# Create development credentials
EDITOR=vim rails credentials:edit --environment development

# Create staging credentials  
EDITOR=vim rails credentials:edit --environment staging

# Create production credentials
EDITOR=vim rails credentials:edit --environment production
```

**Template for Each Environment:**
```yaml
secret_key_base: <generate with: rails secret>

database:
  name: kw_app_<environment>
  username: <username>
  password: <password>
  host: <host>
  port: 5432

redis:
  url: redis://localhost:6379/1
  password: <password>

strava:
  client_id: <client_id>
  client_secret: <client_secret>

payment:
  dotpay_password: <password>

mailgun:
  login: <login>
  password: <password>

openstack:
  tenant: <tenant>
  username: <username>
  api_key: <api_key>
  auth_url: https://auth.cloud.ovh.net/v3
  region: GRA

google:
  static_maps_api_key: <api_key>

# Feature flags (optional)
features:
  use_cloud_storage: true
```

**Action Items:**
- [ ] Copy values from current `.env` to credentials files
- [ ] Generate new `secret_key_base` for each environment: `rails secret`
- [ ] Verify all secrets are present in credentials

### Step 3: Store Master Keys Securely

```bash
# Print master keys (DO NOT COMMIT)
echo "Development key:"
cat config/credentials/development.key

echo "Staging key:"
cat config/credentials/staging.key

echo "Production key:"
cat config/credentials/production.key
```

**Action Items:**
- [ ] Store each key in 1Password with labels:
  - "kw-app Rails Credentials - Development"
  - "kw-app Rails Credentials - Staging"
  - "kw-app Rails Credentials - Production"
- [ ] Share 1Password vault with team member
- [ ] Test retrieval from 1Password

### Step 4: Update Database Configuration

**File:** `config/database.yml`

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  # Support both ENV (legacy) and credentials (new)
  username: <%= ENV.fetch('DB_USER') { Rails.application.credentials.dig(:database, :username) } %>
  password: <%= ENV.fetch('DB_PASSWORD') { Rails.application.credentials.dig(:database, :password) } %>
  host: <%= ENV.fetch('DB_HOST') { Rails.application.credentials.dig(:database, :host) } %>
  port: <%= ENV.fetch('DB_PORT', 5432) %>

development:
  <<: *default
  database: <%= Rails.application.credentials.dig(:database, :name) || 'kw_app_development' %>

staging:
  <<: *default
  database: <%= Rails.application.credentials.dig(:database, :name) || 'kw_app_staging' %>

production:
  <<: *default
  database: <%= Rails.application.credentials.dig(:database, :name) || 'kw_app_production' %>

test:
  <<: *default
  database: kw_app_test
```

### Step 5: Update Initializers

#### `config/initializers/carrierwave.rb`

```ruby
CarrierWave.configure do |config|
  def use_cloud_storage?
    if Rails.env.test?
      false
    else
      # Check credentials first, fallback to ENV
      Rails.application.credentials.dig(:features, :use_cloud_storage) ||
        ENV['USE_CLOUD_STORAGE'].to_s == 'true'
    end
  end
  
  if use_cloud_storage?
    config.fog_provider = 'fog/openstack'
    config.fog_credentials = {
      provider: 'OpenStack',
      openstack_auth_url: Rails.application.credentials.dig(:openstack, :auth_url) || 
                          'https://auth.cloud.ovh.net/v3',
      openstack_username: Rails.application.credentials.dig(:openstack, :username) ||
                          ENV['OPENSTACK_USERNAME'],
      openstack_api_key: Rails.application.credentials.dig(:openstack, :api_key) ||
                         ENV['OPENSTACK_API_KEY'],
      openstack_tenant: Rails.application.credentials.dig(:openstack, :tenant) ||
                        ENV['OPENSTACK_TENANT'],
      openstack_region: Rails.application.credentials.dig(:openstack, :region) || 'GRA'
    }
    
    container_name = if Rails.env.development? && use_cloud_storage?
                       "kw-app-cloud-staging"
                     else
                       Rails.application.credentials.dig(:openstack, :container) ||
                         "kw-app-cloud-#{Rails.env}"
                     end
    
    config.fog_directory = container_name
    config.fog_public = true
  else
    config.storage = :file
    config.enable_processing = true
    config.root = Rails.root
  end
end
```

#### `config/initializers/sidekiq.rb`

```ruby
if Rails.env.staging?
  # Staging configuration
else
  redis_config = {
    password: Rails.application.credentials.dig(:redis, :password) ||
              ENV.fetch('REDIS_PASSWORD', '+eA8tga96sbquDe9CLL3yUZMNdHM6prSwD6kj1vXO4nzPPudDkxh4U+/LMtOWd+Wd72s9MnXNZqCKZeh'),
    url: Rails.application.credentials.dig(:redis, :url) ||
         ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1')
  }
  
  Sidekiq.configure_server do |config|
    config.redis = redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_config
  end
end
```

### Step 6: Update Application Code

#### `app/models/db/activities/mountain_route.rb`

```ruby
# Before
google_maps_api_key = ENV['GOOGLE_STATIC_MAPS_API_KEY']

# After (with fallback)
google_maps_api_key = Rails.application.credentials.dig(:google, :static_maps_api_key) ||
                      ENV['GOOGLE_STATIC_MAPS_API_KEY']
```

#### `app/uploaders/application_uploader.rb`

```ruby
# Before
if Rails.env.production? || Rails.env.staging? || ENV['USE_CLOUD_STORAGE'] == 'true'

# After (with fallback)
def self.use_cloud_storage?
  Rails.application.credentials.dig(:features, :use_cloud_storage) ||
    ENV['USE_CLOUD_STORAGE'] == 'true'
end

if Rails.env.production? || Rails.env.staging? || use_cloud_storage?
  storage :fog
else
  storage :file
end
```

### Step 7: Update Local `.env` File

**File:** `.env` (local development only)

```bash
# Development master key (retrieve from 1Password)
RAILS_MASTER_KEY=<development-key-from-1password>

# Optional: Keep for backward compatibility during migration
# USE_CLOUD_STORAGE=false
```

### Step 8: Test Locally

```bash
# Start development environment
docker-compose down
docker-compose up -d

# Verify credentials are loaded
docker-compose exec -T app rails runner "puts Rails.application.credentials.database.inspect"

# Expected output: {:name=>"kw_app_development", :username=>"...", ...}

# Test database connection
docker-compose exec -T app rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').to_a"

# Test Sidekiq Redis connection
docker-compose exec -T app rails runner "puts Sidekiq.redis { |r| r.ping }"

# Run specs
docker-compose exec -T app bundle exec rspec
```

**Verification Checklist:**
- [ ] Database connection works
- [ ] Redis/Sidekiq connection works
- [ ] File uploads work (local storage)
- [ ] All specs pass
- [ ] No ENV-related warnings in logs

---

## Deployment to Staging

### Step 9: Prepare Staging Credentials

```bash
# Ensure staging credentials are properly set
EDITOR=vim rails credentials:edit --environment staging

# Verify staging credentials file exists and is encrypted
ls -la config/credentials/staging.yml.enc
# Should show: config/credentials/staging.yml.enc

# Verify staging key is NOT committed
git status config/credentials/staging.key
# Should show: untracked or in .gitignore
```

### Step 10: Update Kamal Staging Configuration

**File:** `config/deploy.staging.yml` (if separate) or `config/deploy.yml`

```yaml
# Keep RAILS_MASTER_KEY in secret section
env:
  clear:
    RAILS_ENV: staging
    RACK_ENV: staging
    DB_HOST: kw-app-postgres
    DB_PORT: 5432
  secret:
    - KAMAL_REGISTRY_USERNAME
    - KAMAL_REGISTRY_PASSWORD
    - RAILS_MASTER_KEY
    # Keep these during transition for fallback
    - PRODUCTION_DATABASE_PASSWORD  # temporary
    - REDIS_URL_SIDEKIQ             # temporary
    - OPENSTACK_API_KEY             # temporary
```

### Step 11: Update Local `.env` for Staging

```bash
# Add staging master key to local .env
RAILS_MASTER_KEY=<staging-key-from-1password>
```

### Step 12: Deploy to Staging

```bash
# Build and deploy
kamal deploy

# Or if using separate staging config
kamal deploy -c config/deploy.staging.yml

# Monitor logs
kamal app logs -f

# Verify deployment
curl https://staging.kw.krakow.pl/up
```

### Step 13: Verify Staging Deployment

```bash
# SSH into staging server
ssh ubuntu@<staging-ip>

# Check running containers
docker ps

# Verify credentials are decrypted
kamal app exec "rails runner 'puts Rails.application.credentials.database.inspect'"

# Test database connection
kamal app exec "rails runner 'puts User.count'"

# Test Redis/Sidekiq
kamal app exec "rails runner 'puts Sidekiq.redis { |r| r.ping }'"

# Test file upload (if applicable)
kamal app exec "rails runner 'puts CarrierWave::Uploader::Base.storage'"
```

**Staging Smoke Tests:**
- [ ] Application boots successfully
- [ ] Database queries work
- [ ] Background jobs process
- [ ] File uploads work
- [ ] External API integrations work (Strava, Mailgun, etc.)
- [ ] No credential-related errors in logs

### Step 14: Monitor Staging

```bash
# Watch logs for errors
kamal app logs -f | grep -i "error\|credential\|secret"

# Check error rate
# (Use your monitoring tool - AppSignal, etc.)
```

**Monitor for 24-48 hours before production deployment.**

---

## Deployment to Production

### Step 15: Prepare Production Credentials

```bash
# Edit production credentials
EDITOR=vim rails credentials:edit --environment production

# Triple-check all secrets are correct
rails credentials:show --environment production

# Verify production key
cat config/credentials/production.key
# Store in 1Password if not already done
```

### Step 16: Update Local `.env` for Production

```bash
# Update .env with production master key
RAILS_MASTER_KEY=<production-key-from-1password>
```

### Step 17: Pre-Deployment Checklist

- [ ] Staging has been stable for 24-48 hours
- [ ] All smoke tests passed on staging
- [ ] Production credentials verified
- [ ] Production master key stored in 1Password
- [ ] Rollback plan reviewed
- [ ] Team notified of deployment window
- [ ] Backup of current production ENV variables saved

### Step 18: Deploy to Production

```bash
# Final verification
kamal config

# Deploy
kamal deploy

# Monitor deployment
kamal app logs -f
```

### Step 19: Verify Production Deployment

```bash
# Test health endpoint
curl https://nowypanel.kw.krakow.pl/up

# SSH and verify
ssh ubuntu@146.59.44.70

# Check credentials
kamal app exec "rails runner 'puts Rails.application.credentials.database.inspect'"

# Test critical paths
kamal app exec "rails runner 'puts User.count'"
kamal app exec "rails runner 'puts Sidekiq.redis { |r| r.ping }'"

# Check logs for errors
kamal app logs --tail 100 | grep -i error
```

**Production Smoke Tests:**
- [ ] Application accessible
- [ ] User login works
- [ ] Database operations work
- [ ] Background jobs processing
- [ ] File uploads work
- [ ] Payment processing works (Dotpay)
- [ ] Email sending works (Mailgun)
- [ ] External integrations work (Strava, Google Maps)
- [ ] No error spike in monitoring

### Step 20: Monitor Production

**First Hour:**
- [ ] Watch logs continuously
- [ ] Monitor error rates
- [ ] Check response times
- [ ] Verify background job processing

**First 24 Hours:**
- [ ] Check error rate trends
- [ ] Verify all scheduled jobs run
- [ ] Monitor user reports
- [ ] Check external API call success rates

**First Week:**
- [ ] Review overall stability
- [ ] Check for any credential-related issues
- [ ] Verify all features work correctly

---

## Cleanup

### Step 21: Remove ENV Fallbacks (After 1 Week Stable)

Update all code to remove ENV fallback logic:

```ruby
# Before (with fallback)
Rails.application.credentials.dig(:mailgun, :login) || ENV['MAILGUN_LOGIN']

# After (credentials only)
Rails.application.credentials.mailgun.login
```

**Files to Update:**
- `config/database.yml`
- `config/initializers/carrierwave.rb`
- `config/initializers/sidekiq.rb`
- `app/models/db/activities/mountain_route.rb`
- Any other files using ENV

### Step 22: Update Kamal Configuration

**File:** `config/deploy.yml`

Remove ENV variables now stored in credentials:

```yaml
env:
  clear:
    RAILS_ENV: production
    RACK_ENV: production
    DB_HOST: kw-app-postgres
    DB_PORT: 5432
  secret:
    - KAMAL_REGISTRY_USERNAME
    - KAMAL_REGISTRY_PASSWORD
    - RAILS_MASTER_KEY
    # Removed (now in credentials):
    # - SECRET_KEY_BASE
    # - PRODUCTION_DATABASE_NAME
    # - PRODUCTION_DATABASE_USERNAME
    # - PRODUCTION_DATABASE_PASSWORD
    # - REDIS_URL_SIDEKIQ
    # - STRAVA_CLIENT
    # - STRAVA_SECRET
    # - DOTPAY_PASSWORD
    # - MAILGUN_LOGIN
    # - MAILGUN_PASSWORD
    # - OPENSTACK_TENANT
    # - OPENSTACK_USERNAME
    # - OPENSTACK_API_KEY
```

### Step 23: Update `.env` Template

Create `.env.example` for team reference:

```bash
# .env.example (commit this)
# Development master key (get from 1Password: "kw-app Rails Credentials - Development")
RAILS_MASTER_KEY=

# Docker registry credentials
KAMAL_REGISTRY_USERNAME=
KAMAL_REGISTRY_PASSWORD=

# Optional: For Kamal deployments (get from 1Password)
# RAILS_MASTER_KEY=<staging or production key>
```

### Step 24: Clean Up Local `.env`

```bash
# Keep only essential ENV vars
cat > .env << 'EOF'
# Development master key
RAILS_MASTER_KEY=<your-dev-key>

# Docker registry (for deployments)
KAMAL_REGISTRY_USERNAME=<username>
KAMAL_REGISTRY_PASSWORD=<password>
EOF
```

### Step 25: Update Documentation

**Files to Update:**
- [ ] `README.md` - Add credentials setup instructions
- [ ] `CLAUDE.md` - Update with credentials information
- [ ] `DOCKER_SETUP.md` - Update environment setup

**Add to README.md:**
```markdown
## Secrets Management

This application uses Rails encrypted credentials for secrets management.

### Setup

1. Get the development master key from 1Password: "kw-app Rails Credentials - Development"
2. Add to `.env`: `RAILS_MASTER_KEY=<key>`
3. Verify: `rails credentials:show --environment development`

### Editing Credentials

```bash
# Edit development credentials
EDITOR=vim rails credentials:edit --environment development

# Edit production credentials
EDITOR=vim rails credentials:edit --environment production
```

### Deployment

Master keys are injected via Kamal. Ensure your `.env` has the correct `RAILS_MASTER_KEY` for the target environment.
```

### Step 26: Final Verification

```bash
# Development works without ENV
unset MAILGUN_LOGIN
unset REDIS_PASSWORD
# ... unset all migrated vars

docker-compose restart app
docker-compose exec -T app rails runner "puts 'OK'"

# Staging deployment works
kamal deploy -c config/deploy.staging.yml

# Production deployment works
kamal deploy
```

### Step 27: Archive Old Configuration

```bash
# Move backup files to archive
mkdir -p docs/archive
mv docs/current_env_backup.txt docs/archive/
mv .env.backup docs/archive/

# Commit final state
git add -A
git commit -m "Credentials migration complete - removed ENV fallbacks"
git push
```

---

## Rollback Plan

### If Issues in Staging

```bash
# Revert code changes
git revert <commit-hash>
git push

# Redeploy with ENV variables
kamal deploy -c config/deploy.staging.yml

# Verify rollback
kamal app logs -f
```

### If Issues in Production

**Immediate Rollback (< 5 minutes):**

```bash
# Rollback to previous release
kamal rollback

# Verify
curl https://nowypanel.kw.krakow.pl/up
kamal app logs --tail 100
```

**Code Rollback (if needed):**

```bash
# Revert commits
git revert <commit-range>
git push

# Redeploy
kamal deploy
```

**Master Key Issues:**

```bash
# If master key is incorrect/missing
# 1. Get correct key from 1Password
# 2. Update local .env
# 3. Redeploy
kamal env push
kamal app boot
```

---

## Troubleshooting

### Credentials Won't Decrypt

```bash
# Check master key is set
echo $RAILS_MASTER_KEY

# Verify key matches
rails credentials:show --environment production

# Common issue: Wrong key for environment
# Solution: Get correct key from 1Password
```

### Database Connection Fails

```bash
# Check credentials
rails runner "puts Rails.application.credentials.database.inspect"

# Test connection
rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1')"

# Verify database host/port
docker-compose exec app rails runner "puts ENV['DB_HOST']"
```

### Missing Secret

```bash
# List all credentials
rails credentials:show --environment production

# Add missing secret
EDITOR=vim rails credentials:edit --environment production

# Redeploy
kamal deploy
```

---

## Security Best Practices

### Master Key Management

1. **Never commit master keys** - Always in `.gitignore`
2. **Store in 1Password** - Central, secure, team-accessible
3. **Rotate annually** - Generate new keys and re-encrypt
4. **Limit access** - Only team members who need it
5. **Audit access** - Review 1Password access logs

### Credentials Files

1. **Commit encrypted files** - `.yml.enc` files are safe to commit
2. **Review changes** - Treat credential edits like code changes
3. **Separate by environment** - Never share production secrets with staging
4. **Minimal secrets** - Only store what's necessary

### Deployment Security

1. **Inject at runtime** - Master key via ENV, never in image
2. **Private registry** - Use authenticated Docker registry
3. **Secure .env** - Never commit `.env` files
4. **Audit deployments** - Log who deployed what when

---

## Success Criteria

- [ ] All environments using encrypted credentials
- [ ] No ENV variables for application secrets in Kamal config
- [ ] All team members can access master keys via 1Password
- [ ] Documentation updated
- [ ] Zero production incidents related to migration
- [ ] Successful deployments to staging and production
- [ ] All tests passing
- [ ] Rollback plan tested

---

## Timeline

- **Week 1**: Steps 1-8 (Development setup and testing)
- **Week 2**: Steps 9-14 (Staging deployment and monitoring)
- **Week 3**: Steps 15-20 (Production deployment and monitoring)
- **Week 4**: Steps 21-27 (Cleanup and documentation)

---

## References

- [Rails Encrypted Credentials Guide](https://edgeguides.rubyonrails.org/security.html#custom-credentials)
- [Kamal Documentation](https://kamal-deploy.org/)
- Project: `CLAUDE.md` - Deployment guidelines