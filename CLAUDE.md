# Claude AI Guidelines for kw-app

> Context and behavioral guidelines for AI assistants. **For commands and Zed agents**, see [.agents/](.agents/)

---

## 📦 Project Versions

**Ruby:** 3.2.2  
**Rails:** 7.0.8  
**PostgreSQL:** 10.3  
**Redis:** 7  

---

## 🚫 Restrictions

**Require approval:**
- Production database modifications or data deletion
- Modifying deployment configs (`config/deploy.*.yml`)
- Destructive git operations (commit, push, pull, merge, rebase, reset)
- Ask once per thread, then freely use approved operations

**Never:**
- Hardcode secrets/credentials
- Remove security features

---

## 📖 Project Context

**kw-app** is a Rails monolith with background jobs (Sidekiq), file uploads (CarrierWave), containerized deployment (Docker + Kamal).

**Architecture:**
- Monolithic Rails app
- Background jobs via Sidekiq
- PostgreSQL + Redis
- Zero-downtime deployment via Kamal

**Key patterns:**
- Service objects in `app/services/` for complex logic
- Background jobs in `app/jobs/` for async tasks

---

## 🎯 AI Working Guidelines

### Environment Setup

⚠️ **CRITICAL - Docker vs Native Ruby:**
- **Docker (99% of commands)**: Use `docker-compose exec -T app` for ALL app commands
  - Tests: `docker-compose exec -T app bundle exec rspec`
  - Console: `docker-compose exec app bundle exec rails console`
  - Rake tasks: `docker-compose exec -T app bundle exec rake`
  - Rails runner: `docker-compose exec -T app bundle exec rails runner`
- **Native Ruby (Kamal ONLY)**: Local machine uses chruby 3.2.2 for deployment
  - Kamal staging: `zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d staging -i --reuse "bin/rails console"'`
  - Kamal production: `zsh -c 'source ~/.zshrc && chruby 3.2.2 && bundle exec kamal app exec -d production -i --reuse "bin/rails console"'`
  - **`--reuse` flag**: Reuses existing SSH connection, doesn't require registry credentials
- **CI/GitHub Actions**: Uses docker-compose with `-T` flag (same as local)

**Why?**
- App runs in Docker (Ruby 3.2.2 + Rails 7.0.8) with consistent environment
- Kamal deployment tool runs on host machine with native chruby Ruby
- **Why "Run tests outside Docker" is forbidden**: Tests need the full Docker environment (PostgreSQL, Redis, exact gem versions). Running tests on host would use wrong Ruby version (system Ruby 2.6.10 ≠ app Ruby 3.2.2) and miss container dependencies.

### Docker Commands (CI/GitHub Actions Only)

**Use `-T` flag for non-interactive commands:**
- Tests, migrations, rake tasks: `docker-compose exec -T app bundle exec rspec`

**No `-T` flag for interactive commands:**
- Rails console, bash: `docker-compose exec app bundle exec rails console`

**Always check containers first:** `docker-compose ps`
**When not running:** `docker-compose up -d`

### Testing

⚠️ **CRITICAL:** Always use Docker for tests!

- **Run tests:** `docker-compose exec -T app bundle exec rspec`
- **Specific file:** `docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb`
- **Specific line:** `docker-compose exec -T app bundle exec rspec spec/models/user_spec.rb:25`
- Always write tests for new features
- Use FactoryBot for test data
- Verify tests pass before considering work complete

**Why Docker is mandatory for tests:**
- System Ruby (2.6.10) ≠ App Ruby (3.2.2)
- Tests need PostgreSQL 10.3 and Redis 7 from containers
- Exact gem versions from container's bundle
- Consistent CI/local environment

**Test Output Verbosity:**
- By default, tests run in **quiet mode** (log level: `:warn`) - SQL queries and debug logs hidden
- Enable verbose output for debugging: `VERBOSE_TESTS=true bundle exec rspec`
- Verbose mode shows: SQL queries, ActiveRecord logs, cache hits, SASS warnings
- Use verbose mode only when debugging specific issues

### Migrations

1. Test locally first
2. Make reversible (use `up`/`down` or reversible methods)
3. Review SQL it generates
4. Test on staging before production
5. Separate data migrations from schema changes

### Code Organization

- **Business logic**: Models first, extract to `app/services/` when complex
- **Controllers**: Thin, delegate to models/services
- **Background jobs**: `app/jobs/` for anything >500ms
- **File naming**: Services: `resource/action.rb`, Jobs: `resource_action_job.rb`

### Debugging

1. **Check [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md)** for documented migration issues
2. Check logs (see .agents/README.md)
3. Reproduce locally
4. Add logging/pry breakpoints
5. Fix root cause, not symptoms
6. Write test first (TDD)
7. **Update KNOWN_ISSUES.md** when you discover a new pattern/bug

### Secrets

- Stored in `config/credentials/*.yml.enc` (encrypted)
- Master keys in Bitwarden (never commit)
- Edit locally: `EDITOR=vim bin/rails credentials:edit --environment development`
- Edit in CI: `docker-compose exec app bash -c "EDITOR=vim bin/rails credentials:edit --environment development"`

---

## 🔄 Common Workflows

### Adding Gem
1. Edit `Gemfile`
2. Restart containers: `docker-compose restart app sidekiq` (auto-installs via entrypoint)
3. Verify in logs

### Debugging Production
1. Check logs
2. Reproduce locally
3. Fix and test in development
4. Deploy to staging, verify
5. Human deploys to production

### Database Changes
1. Write migration
2. Test: `rake db:migrate` then `rake db:rollback`
3. Review `db/schema.rb`
4. Write tests
5. Deploy to staging first

### New Features
1. Write failing test (TDD)
2. Implement minimal code
3. Refactor
4. Run full test suite
5. Manual testing

---

## 💻 Rails Console Scripts

**When user asks to "write a console script" or similar:**

1. **Provide inline Ruby code** for copy/paste into `rails console`
2. **Always wrap in `ActiveRecord::Base.logger.silence do ... end`** to keep output clean
3. **Format as single code block** ready for immediate execution
4. **Include minimal comments** only when logic is complex

**Recommended format:**
```ruby
ActiveRecord::Base.logger.silence do
  User.where(active: true).find_each do |user|
    user.update(status: 'verified')
  end
  puts "Done!"
end
```

**Avoid:**
- Creating `.rb` files or using `rails runner`
- Running commands without explicit user request
- Verbose explanations before the code

**For Zed editor users:**
- Use `@console-agent` in Zed for console script assistance
- Reference `.agents/*.md` for specialized patterns (models, services, jobs, debugging, etc.)
- All commands use Docker except Kamal deployment

---

## 🧠 Decision Making

**Use background jobs for:**
- Operations taking >500ms
- External API calls
- Email/file processing
- Batch operations

**Use service objects for:**
- Logic spanning multiple models
- Complex business rules (>20 lines)
- External integrations

**Service Pattern (dry-monads REQUIRED):**
- **NEW services**: MUST use `dry-monads` with `:result` and `:do` notation
- **Legacy services**: Migrate from custom `Result` classes to `dry-monads` when touched
- Return `Success(value)` or `Failure(error)`
- See `.agents/service.md` and `docs/KNOWN_ISSUES.md` for patterns

**Implement caching for:**
- Expensive queries run frequently
- External API responses (with TTL)
- Complex calculations

---

## 📝 Conventions

**Naming:**
- Models: `User`, `BlogPost` (singular)
- Controllers: `UsersController` (plural)
- Services: `User::Create`, `Report::Generate`
- Jobs: `UserNotificationJob`

**Testing:**
- Model specs: Validations, associations, methods
- Controller specs: Request/response, authorization
- Service specs: Business logic
- Integration specs: Complex flows

---

## 🚀 Deployment

**Staging (Raspberry Pi):**
- ARM64 architecture
- Limited memory (~4GB) - run DB tasks separately
- Automated via GitHub Actions (push to `develop` branch)
- Self-hosted runner on the Pi
- Test before production

**Production (VPS):**
- x86_64 architecture
- Automated via GitHub Actions (push to `main` branch)
- Zero-downtime (Kamal rolling restart)
- Migrations run before new containers

**Key considerations:**
- Pi has memory limits (run large seeds in batches)
- GitHub Actions handles testing + deployment automatically
- CarrierWave uses local storage in test, OpenStack in production
- Sidekiq web UI available at `/sidekiq`

---

## 📚 References

- **Specialized Agents:** `.agents/*.md` (console, model, service, rspec, debug, browser, job, refactor)
- **Setup:** [README.md](README.md)
- **Known Issues:** [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) ⚠️ **Check first when debugging!**
- **Server provisioning:** [ansible/README.md](ansible/README.md)
- **Credentials:** [docs/RAILS_ENCRYPTED_CREDENTIALS.md](docs/RAILS_ENCRYPTED_CREDENTIALS.md)