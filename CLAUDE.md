# Claude AI Guidelines for kw-app

> Quick-start guide and behavioral rules for AI assistants. **For specialized tasks**, see [.agents/](.agents/)

---

## 📦 Quick Reference

| Item | Value |
|------|-------|
| **Ruby** | 3.2.2 |
| **Rails** | 7.0.8 |
| **PostgreSQL** | 10.3 |
| **Redis** | 7 |
| **Architecture** | Monolith with Sidekiq, CarrierWave, Docker + Kamal |

---

## ⚡ Essential Commands

### Testing (Always in Docker)
```bash
# Run all tests
docker-compose exec -T app bundle exec rspec

# Specific file
docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb

# Specific line
docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb:25

# Verbose mode (for debugging)
docker-compose exec -T app env VERBOSE_TESTS=true bundle exec rspec
```

### Console Access
```bash
# Development (interactive - no -T flag)
docker-compose exec app bundle exec rails console

# Staging (via Kamal with native Ruby)
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d staging -i --reuse "bin/rails console"'

# Production (via Kamal with native Ruby)
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d production -i --reuse "bin/rails console"'
```

### Database Operations
```bash
# Run migrations
docker-compose exec -T app bundle exec rake db:migrate

# Rollback
docker-compose exec -T app bundle exec rake db:rollback

# Database console
docker-compose exec app bundle exec rails dbconsole
```

### Container Management
```bash
# Check status
docker-compose ps

# Start services
docker-compose up -d

# View logs
docker-compose logs -f app

# Restart after Gemfile changes
docker-compose restart app sidekiq
```

---

## 🚫 Boundaries (Critical - Read First!)

### ✅ Always Do
- **Use Docker for ALL app commands** (tests, console, rake tasks, rails runner)
- **Write tests for new features** using RSpec + FactoryBot
- **Use dry-monads for service objects** (`Success(value)` / `Failure(error)`)
- **Check [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) before debugging**
- **Run tests before marking work complete**
- **Follow single responsibility principle** (thin models/controllers)

### ⚠️ Ask First (Once Per Thread)
- **Production database modifications or deletions**
- **Deployment config changes** (`config/deploy.*.yml`)
- **Git operations** (commit, push, pull, merge, rebase, reset)
- **Database migrations** (must be reversible and tested)
- **Adding gems to Gemfile** (restart containers after approval)
- **Modifying existing validations or associations**

### 🚫 Never Do
- **Hardcode secrets or credentials** (use encrypted credentials)
- **Remove security features**
- **Run tests outside Docker** (wrong Ruby version, missing dependencies)
- **Use custom Result classes** (`require 'result'` - DEPRECATED, use dry-monads)
- **Skip tests**
- **Modify `vendor/`, `node_modules/`, or `.git/` directories**
- **Commit `*.key` files or credentials**

---

## 🎯 When to Use Which Agent

| Need to... | Use Agent | Example |
|------------|-----------|---------|
| Write console script | [@console](.agents/console.md) | "Return all active users" |
| Create/modify models | [@model](.agents/model.md) | "Add User model with validations" |
| Create service objects | [@service](.agents/service.md) | "Create payment processing service" |
| Write/run tests | [@rspec](.agents/rspec.md) | "Test User authentication" |
| Debug issues | [@debug](.agents/debug.md) | "Fix login redirect issue" |
| Browser automation | [@browser](.agents/browser.md) | "Test form submission" |
| Background jobs | [@job](.agents/job.md) | "Create email notification job" |
| Refactor code | [@refactor](.agents/refactor.md) | "Extract service from controller" |

**Don't know which agent?** Describe your task and I'll recommend the right specialist.

---

## 📂 Project Structure

```
kw-app/
├── app/
│   ├── models/db/              # ActiveRecord models (Db::User, Db::Profile)
│   ├── components/             # Operations (services) & contracts (forms)
│   │   └── */operation/        # Business logic with dry-monads
│   ├── controllers/            # Thin controllers (delegate to services)
│   ├── jobs/                   # Background jobs (Sidekiq)
│   ├── mailers/                # Email templates
│   └── views/                  # ERB templates
├── spec/                       # RSpec tests (mirrors app/ structure)
│   ├── models/
│   ├── components/
│   ├── requests/               # HTTP integration tests (preferred)
│   └── factories/              # FactoryBot factories
├── config/
│   ├── credentials/            # Encrypted secrets (⚠️ ask before editing)
│   └── deploy.*.yml            # Kamal deployment configs (⚠️ ask first)
├── db/
│   ├── migrate/                # Database migrations (⚠️ must be reversible)
│   └── schema.rb               # Current database schema (auto-generated)
└── docs/                       # Documentation
    └── KNOWN_ISSUES.md         # ⚠️ Check this first when debugging!
```

---

## 🏗️ Architecture Patterns

### Service Objects (dry-monads REQUIRED)

**✅ Good - Use dry-monads:**
```ruby
class Users::Operation::Create
  include Dry::Monads[:result, :do]
  
  def call(params:)
    user_params = yield validate!(params)
    user        = yield persist!(user_params)
    
    Success(user)
  end
  
  private
  
  def validate!(params)
    contract = Users::Contract::Create.new.call(params)
    return Failure(contract.errors.to_h) unless contract.success?
    Success(contract.to_h)
  end
  
  def persist!(params)
    user = User.create(params)
    user.persisted? ? Success(user) : Failure(user.errors)
  end
end
```

**❌ Bad - Custom Result classes (DEPRECATED):**
```ruby
require 'result'  # ❌ Don't use these!
require 'success'
require 'failure'

class SomeService
  def call
    return Failure(:invalid, errors: {}) unless valid?
    Success(:success)
  end
end
```

### Thin Controllers

**✅ Good - Delegate to services:**
```ruby
class UsersController < ApplicationController
  def create
    result = Users::Operation::Create.new.call(params: user_params)
    
    case result
    in Success(user)
      redirect_to user, notice: 'User created'
    in Failure(errors)
      @errors = errors
      render :new, status: :unprocessable_entity
    end
  end
end
```

**❌ Bad - Business logic in controller:**
```ruby
def create
  @user = User.new(user_params)
  if @user.save
    UserMailer.welcome(@user).deliver_later
    redirect_to @user
  else
    render :new
  end
end
```

### Background Jobs

**When to use:**
- Operations taking >500ms
- External API calls
- Email/file processing
- Batch operations

**✅ Good - Pass IDs, not objects:**
```ruby
class UserNotificationJob < ApplicationJob
  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user
    
    UserMailer.welcome(user).deliver_now
  end
end

# Enqueue from service
UserNotificationJob.perform_later(user.id)
```

---

## 🔧 Docker vs Native Ruby

### Docker (99% of commands)
**Use `docker-compose exec -T app` for ALL app commands:**
- Tests: `docker-compose exec -T app bundle exec rspec`
- Console: `docker-compose exec app bundle exec rails console` (interactive, no `-T`)
- Rake tasks: `docker-compose exec -T app bundle exec rake`
- Rails runner: `docker-compose exec -T app bundle exec rails runner`

**Why Docker is mandatory:**
- System Ruby (2.6.10) ≠ App Ruby (3.2.2)
- Tests need PostgreSQL 10.3 and Redis 7 from containers
- Exact gem versions from container's bundle
- Consistent CI/local environment

### Native Ruby (Kamal ONLY)
**Local machine uses chruby 3.2.2 for deployment commands:**
```bash
# Kamal commands run on host with native Ruby
zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d staging -i --reuse "bin/rails console"'
```

**Kamal flags:**
- `-i` / `--interactive`: Keep terminal interactive (required for console)
- `--reuse`: Reuse existing SSH connection, no registry credentials needed
- `-d staging` / `-d production`: Specify destination environment

---

## 📝 Conventions & Standards

### Naming Conventions
- **Models:** Singular PascalCase (`User`, `BlogPost`)
- **Controllers:** Plural + Controller (`UsersController`, `BlogPostsController`)
- **Services:** `Namespace::Operation::Action` (`Users::Operation::Create`)
- **Jobs:** Action + Job (`UserNotificationJob`, `EmailDigestJob`)
- **Specs:** Match source + `_spec.rb` (`user_spec.rb`, `users_controller_spec.rb`)

### File Organization
- **Business logic:** Extract to `app/components/*/operation/` when >20 lines
- **Controllers:** Thin, delegate to services
- **Models:** Data + persistence, not business logic
- **Jobs:** Background work, pass IDs not objects

### Testing Standards
- **Request specs preferred** over controller specs (tests full HTTP stack)
- **FactoryBot** for test data (never hardcode IDs)
- **One expectation per test** when possible
- **TDD workflow:** RED → GREEN → REFACTOR

---

## 🔄 Common Workflows

### Adding a New Feature
1. **Check** [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for related patterns
2. **Write failing test** (TDD) using `@rspec`
3. **Implement** using appropriate agent (`@model`, `@service`, etc.)
4. **Run tests:** `docker-compose exec -T app bundle exec rspec`
5. **Refactor** if needed using `@refactor`
6. **Manual testing** in development

### Debugging an Issue
1. **Check** [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) first!
2. **Reproduce** locally using `@debug` or `@browser`
3. **Add logging** temporarily (remove after)
4. **Fix root cause**, not symptoms
5. **Write regression test**
6. **Update KNOWN_ISSUES.md** if new pattern discovered

### Database Changes
1. **Write migration** (must be reversible)
2. **Test locally:** `rake db:migrate` then `rake db:rollback`
3. **Review** `db/schema.rb` changes
4. **Write tests** for model changes
5. **Deploy to staging first**
6. **Human approves** production deployment

### Adding a Gem
1. **Edit** `Gemfile`
2. **Restart containers:** `docker-compose restart app sidekiq` (auto-installs via entrypoint)
3. **Verify** in logs: `docker-compose logs app | grep bundle`

---

## 💻 Rails Console Scripts

### Quick Script Format
When user asks to "write a console script" or similar:

```ruby
ActiveRecord::Base.logger.silence do
  User.where(active: true).find_each do |user|
    user.update(status: 'verified')
  end
  puts "Done! Updated #{User.where(status: 'verified').count} users"
end
```

**Guidelines:**
- ✅ Wrap in `ActiveRecord::Base.logger.silence` for clean output
- ✅ Use `find_each` for large datasets (batches of 1000)
- ✅ Include confirmation output with counts
- ✅ Single code block ready for copy/paste
- ❌ Don't create `.rb` files unless requested
- ❌ Don't run commands without explicit user request

**For direct execution:** See [@console](.agents/console.md) for two-mode approach.

---

## 🔐 Secrets Management

- **Storage:** Encrypted in `config/credentials/*.yml.enc`
- **Master keys:** In Bitwarden (never commit)
- **Edit locally:**
  ```bash
  docker-compose exec app bash -c "EDITOR=vim bin/rails credentials:edit --environment development"
  ```
- **Never:** Hardcode secrets or commit `*.key` files

**See:** [docs/RAILS_ENCRYPTED_CREDENTIALS.md](docs/RAILS_ENCRYPTED_CREDENTIALS.md)

---

## 🚀 Deployment

### Staging (Raspberry Pi)
- **Architecture:** ARM64
- **Memory:** ~4GB (run DB tasks in batches)
- **Trigger:** Push to `develop` branch
- **Method:** GitHub Actions (self-hosted runner on Pi)

### Production (VPS)
- **Architecture:** x86_64
- **Trigger:** Push to `main` branch
- **Method:** GitHub Actions + Kamal
- **Zero-downtime:** Rolling restart, migrations run before new containers

**Key considerations:**
- Test on staging first
- Pi has memory limits (batch large operations)
- Sidekiq web UI: `/sidekiq`
- CarrierWave: local storage (test), OpenStack (production)

---

## 📚 Additional Resources

- **Specialized Agents:** [.agents/](.agents/) - console, model, service, rspec, debug, browser, job, refactor
- **Known Issues:** [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) ⚠️ **Check first when debugging!**
- **Setup Guide:** [README.md](README.md)
- **Server Provisioning:** [ansible/README.md](ansible/README.md)
- **Credentials Management:** [docs/RAILS_ENCRYPTED_CREDENTIALS.md](docs/RAILS_ENCRYPTED_CREDENTIALS.md)

---

## 🔄 Version History

### v2.0 (2024-01)
- ✅ Migrated to dry-monads (custom Result classes deprecated)
- ✅ Restructured with commands early (GitHub best practices)
- ✅ Added clear three-tier boundaries
- ✅ Removed duplications across agent files
- ✅ Added explicit project structure

### v1.0 (2023)
- Initial agent structure with custom Result pattern