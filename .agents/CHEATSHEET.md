# kw-app Cheat Sheet

> Quick reference for common commands. All app commands run in Docker!

---

## 🐳 Docker Commands

### Container Management
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart app
docker-compose restart sidekiq

# Check status
docker-compose ps

# View logs
docker-compose logs -f app
docker-compose logs -f sidekiq

# Rebuild after Gemfile changes
docker-compose build app
docker-compose restart app sidekiq
```

---

## 🧪 Testing (ALWAYS in Docker)

### Basic Test Commands
```bash
# Run all tests
docker-compose exec -T app bundle exec rspec

# Specific file
docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb

# Specific line
docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb:25

# Pattern match
docker-compose exec -T app bundle exec rspec spec/models/

# Verbose output (debugging)
docker-compose exec -T app env VERBOSE_TESTS=true bundle exec rspec

# Fast fail (stop on first failure)
docker-compose exec -T app bundle exec rspec --fail-fast

# Documentation format
docker-compose exec -T app bundle exec rspec --format documentation

# With coverage
COVERAGE=true docker-compose exec -T app bundle exec rspec
```

---

## 💻 Rails Console

### Development Console (Interactive - NO -T flag)
```bash
docker-compose exec app bundle exec rails console
```

### Staging Console (via Kamal with Native Ruby)
```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d staging -i --reuse "bin/rails console"'
```

### Production Console (via Kamal with Native Ruby)
```bash
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d production -i --reuse "bin/rails console"'
```

---

## 🗄️ Database

### Migrations
```bash
# Run migrations
docker-compose exec -T app bundle exec rake db:migrate

# Rollback last migration
docker-compose exec -T app bundle exec rake db:rollback

# Rollback multiple steps
docker-compose exec -T app bundle exec rake db:rollback STEP=3

# Check migration status
docker-compose exec -T app bundle exec rake db:migrate:status

# Reset database (DANGEROUS - development only!)
docker-compose exec -T app bundle exec rake db:reset
```

### Database Console
```bash
# PostgreSQL console
docker-compose exec app bundle exec rails dbconsole

# Or direct psql
docker-compose exec db psql -U postgres kw_app_development
```

---

## 🚀 Deployment (Kamal - Native Ruby ONLY)

### Deploy Commands
```bash
# Deploy to staging
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal deploy -d staging'

# Deploy to production
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal deploy -d production'

# Deploy specific branch
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal deploy -d staging --version=feature-branch'

# Rollback
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal rollback -d production'
```

### Deployment Monitoring
```bash
# Check status
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app details -d staging'

# View logs
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app logs -d staging'

# Tail logs
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app logs -d staging --tail 100'
```

### Remote Commands
```bash
# Run rake task on remote
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d staging --reuse "bin/rails db:migrate:status"'

# Run rails runner on remote
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d staging --reuse "bin/rails runner \"puts User.count\""'
```

---

## 🔧 Rails Commands (in Docker)

### Generators
```bash
# Generate model
docker-compose exec -T app bundle exec rails g model User email:string name:string

# Generate migration
docker-compose exec -T app bundle exec rails g migration AddAgeToUsers age:integer

# Generate service
docker-compose exec -T app bundle exec rails g service users/create

# Generate job
docker-compose exec -T app bundle exec rails g job UserNotification
```

### Rake Tasks
```bash
# List all tasks
docker-compose exec -T app bundle exec rake -T

# Custom rake task
docker-compose exec -T app bundle exec rake custom:task

# Environment info
docker-compose exec -T app bundle exec rake about
```

---

## 📦 Dependencies

### Bundler
```bash
# Install gems (after Gemfile changes)
# Note: Entrypoint auto-installs, but manual command:
docker-compose exec -T app bundle install

# Update specific gem
docker-compose exec -T app bundle update gem_name

# Check outdated gems
docker-compose exec -T app bundle outdated
```

### After Adding Gem
```bash
# Restart containers (entrypoint will bundle install)
docker-compose restart app sidekiq

# Verify in logs
docker-compose logs app | grep bundle
```

---

## 🔍 Debugging

### Check Logs
```bash
# Application logs
docker-compose logs -f app

# Sidekiq logs
docker-compose logs -f sidekiq

# PostgreSQL logs
docker-compose logs -f db

# Redis logs
docker-compose logs -f redis
```

### Interactive Debugging
```bash
# Rails console with debugging
docker-compose exec app bundle exec rails console

# Check routes
docker-compose exec -T app bundle exec rails routes

# Check routes for specific pattern
docker-compose exec -T app bundle exec rails routes | grep users
```

---

## 🔐 Credentials

### Edit Credentials
```bash
# Development
docker-compose exec app bash -c "EDITOR=vim bin/rails credentials:edit --environment development"

# Staging (if needed)
docker-compose exec app bash -c "EDITOR=vim bin/rails credentials:edit --environment staging"

# Production (if needed)
docker-compose exec app bash -c "EDITOR=vim bin/rails credentials:edit --environment production"
```

---

## 🧹 Maintenance

### Clear Caches
```bash
# Rails cache
docker-compose exec -T app bundle exec rails runner "Rails.cache.clear"

# Tmp files
docker-compose exec -T app bundle exec rake tmp:clear

# Assets
docker-compose exec -T app bundle exec rake assets:clobber
```

### Database Cleanup
```bash
# Vacuum (PostgreSQL)
docker-compose exec db psql -U postgres -d kw_app_development -c "VACUUM ANALYZE;"

# Check database size
docker-compose exec db psql -U postgres -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) FROM pg_database;"
```

---

## 🎯 Quick Workflows

### Adding a New Feature (TDD)
```bash
# 1. Write failing test
docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb

# 2. Implement feature
# (edit files)

# 3. Run tests again
docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb

# 4. Run all tests before commit
docker-compose exec -T app bundle exec rspec
```

### Database Migration Workflow
```bash
# 1. Generate migration
docker-compose exec -T app bundle exec rails g migration AddEmailToUsers email:string

# 2. Edit migration file
# (edit db/migrate/...)

# 3. Run migration
docker-compose exec -T app bundle exec rake db:migrate

# 4. Test rollback
docker-compose exec -T app bundle exec rake db:rollback

# 5. Re-run migration
docker-compose exec -T app bundle exec rake db:migrate

# 6. Verify schema
git diff db/schema.rb
```

### Background Job Testing
```bash
# 1. Open console
docker-compose exec app bundle exec rails console

# 2. Test job
> UserNotificationJob.perform_now(user_id: 1)

# 3. Check Sidekiq web UI
# Visit: http://localhost:3000/sidekiq
```

---

## ⚠️ CRITICAL REMINDERS

### ✅ ALWAYS Do
- Use `docker-compose exec -T app` for non-interactive commands
- Use `docker-compose exec app` (no `-T`) for interactive console
- Run tests in Docker (never on host)
- Use `zsh -c 'source ~/.zshrc && chruby 3.2.2 && ...'` for Kamal commands

### 🚫 NEVER Do
- Run tests on host: `bundle exec rspec` ❌
- Use system Ruby for app commands ❌
- Skip the `-T` flag for non-interactive commands ❌
- Use Docker for Kamal deployment commands ❌

---

## 📚 Additional Resources

- **Main Guidelines**: [CLAUDE.md](../CLAUDE.md)
- **Agent Discovery**: [.agents/README.md](README.md)
- **Skills Library**: [.agents/skills/](skills/)
- **Known Issues**: [docs/KNOWN_ISSUES.md](../docs/KNOWN_ISSUES.md)

---

**Quick Help**: "I need help with X" → Check [Agent README](README.md) for which agent to use!

**Version**: 2.0  
**Last Updated**: 2024-01