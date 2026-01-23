# Claude AI Guidelines for kw-app

> Context and behavioral guidelines for AI assistants. **For commands and Zed agents**, see [.agents/](.agents/)

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

⚠️ **CRITICAL - Local vs CI:**
- **Local machine**: Uses chruby + native Ruby 3.2.2 (NOT docker-compose)
- **CI/GitHub Actions**: Uses docker-compose with `-T` flag
- For local commands, run directly: `bundle exec rspec`, `rails console`, etc.
- See `.agents/README.md` for exact local setup details

### Docker Commands (CI/GitHub Actions Only)

**Use `-T` flag for non-interactive commands:**
- Tests, migrations, rake tasks: `docker-compose exec -T app bundle exec rspec`

**No `-T` flag for interactive commands:**
- Rails console, bash: `docker-compose exec app bundle exec rails console`

**Always check containers first:** `docker-compose ps`
**When not running:** `docker-compose up -d`

### Testing

- Always write tests for new features
- Run full test suite before suggesting complete: `bundle exec rspec` (local) or `docker-compose exec -T app bundle exec rspec` (CI)
- Use FactoryBot for test data
- Verify tests pass in CI before considering work complete

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
- All infrastructure details (chruby, docker, ports) in `.agents/README.md`
- Reference `.agents/` for exact commands - don't guess or try variations
- Commands work with local setup (chruby 3.2.2, native Ruby - NOT docker-compose)

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
- Manual deployment
- Test before production

**Production (VPS):**
- x86_64 architecture
- Automated via GitHub Actions (push to `deploy` branch)
- Zero-downtime (Kamal rolling restart)
- Migrations run before new containers

**Key considerations:**
- Pi has memory limits (run large seeds in batches)
- GitHub Actions handles testing + deployment automatically
- CarrierWave uses local storage in test, OpenStack in production
- Sidekiq web UI available at `/sidekiq`

---

## 📚 References

- Commands: [AGENTS.md](AGENTS.md)
- Setup: [README.md](README.md)
- Known Issues: [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) ⚠️ **Check first when debugging!**
- Server provisioning: [ansible/README.md](ansible/README.md)
- Docker: [docs/DOCKER_SETUP.md](docs/DOCKER_SETUP.md)
- Credentials: [docs/RAILS_ENCRYPTED_CREDENTIALS.md](docs/RAILS_ENCRYPTED_CREDENTIALS.md)