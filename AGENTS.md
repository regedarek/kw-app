# Agents

> Available agents for kw-app and when to use them.

---

## Quick Decision Tree

```
What do you need to do?
├─ Run code in Rails console        → @console
├─ Create/modify a model            → @model
├─ Write a service object           → @service
├─ Write/run tests                  → @rspec
├─ Debug an issue                   → @debug
├─ Test in browser                  → @browser
├─ Create background job            → @job
├─ Refactor existing code           → @refactor
├─ Plan a new feature               → @feature-planner
├─ Review implementation            → @review
└─ Security audit                   → @security
```

---

## Agent Inventory

### Implementation Agents

| Agent | Purpose | When to Use | When NOT to Use |
|-------|---------|-------------|-----------------|
| **[@console](.agents/console.md)** | Rails console scripts | Data queries, quick updates, manual testing | Creating files, running tests |
| **[@model](.agents/model.md)** | ActiveRecord models | Creating/modifying models, migrations | Business logic (use @service) |
| **[@service](.agents/service.md)** | Service objects with dry-monads | Business logic, multi-step operations | Simple CRUD without logic |
| **[@job](.agents/job.md)** | Background jobs (Sidekiq) | Async processing, emails, batch operations | Immediate response needed |

### Testing & Quality Agents

| Agent | Purpose | When to Use | When NOT to Use |
|-------|---------|-------------|-----------------|
| **[@rspec](.agents/rspec.md)** | Write and run tests | TDD, adding test coverage | Implementation (use specific agent) |
| **[@debug](.agents/debug.md)** | Troubleshoot issues | Bug investigation, log analysis | Writing new features |
| **[@browser](.agents/browser.md)** | Browser automation | UI testing, reproducing issues | API-only testing |
| **[@review](.agents/review.md)** | Code review | Before merge, quality check | During implementation |
| **[@security](.agents/security.md)** | Security audit | Vulnerability checks, auth review | Regular feature development |

### Planning & Maintenance Agents

| Agent | Purpose | When to Use | When NOT to Use |
|-------|---------|-------------|-----------------|
| **[@feature-planner](.agents/feature-planner.md)** | Feature planning | New features, breaking down requirements | Simple bug fixes |
| **[@refactor](.agents/refactor.md)** | Code refactoring | Improving structure, reducing complexity | Adding new functionality |

---

## Common Workflows

### Adding a New Feature (Full TDD)

```
1. @feature-planner  → Analyze requirements, create plan
2. @model            → Create database schema
3. @rspec            → Write failing tests
4. @service          → Implement business logic
5. @rspec            → Run tests, verify passing
6. @review           → Check implementation
7. @refactor         → Improve if needed
```

### Quick Script Execution

```
1. @console → Write and execute script
```

### Debugging Production Issue

```
1. @debug   → Investigate error, reproduce
2. @rspec   → Add regression test
3. @review  → Verify fix
```

### Background Job Setup

```
1. @job     → Create job class
2. @rspec   → Write job tests
3. @service → Integrate with operation
4. @console → Test manually
```

---

## Agent Selection Guide

| Problem | Agent |
|---------|-------|
| "Build a new feature" | `@feature-planner` → then implementation agents |
| "Create a user model" | `@model` |
| "Write business logic" | `@service` |
| "Run my tests" | `@rspec` |
| "Fix this bug" | `@debug` |
| "Send emails in background" | `@job` |
| "Check this in console" | `@console` |
| "Test form submission in browser" | `@browser` |
| "Review my changes" | `@review` |
| "Check for security issues" | `@security` |
| "Clean up this code" | `@refactor` |

---

## Skills Library

Deep-dive knowledge modules for specific patterns:

| Skill | Path | Purpose |
|-------|------|---------|
| **dry-monads-patterns** | `.agents/skills/dry-monads-patterns/` | Success/Failure monad patterns |
| **activerecord-patterns** | `.agents/skills/activerecord-patterns/` | ActiveRecord best practices |
| **testing-standards** | `.agents/skills/testing-standards/` | RSpec + FactoryBot patterns |
| **rails-service-object** | `.agents/skills/rails-service-object/` | Service object architecture |
| **performance-optimization** | `.agents/skills/performance-optimization/` | N+1 prevention, caching |
| **kamal-deployment** | `.agents/skills/kamal-deployment/` | Zero-downtime deployment |

---

## Project Rules (All Agents)

All agents MUST follow kw-app conventions:

- ✅ Use Docker for ALL app commands
- ✅ Use dry-monads for operations (`Success(value)` / `Failure(error)`)
- ✅ Write tests before marking work complete
- ✅ Check `docs/KNOWN_ISSUES.md` when debugging

- ⚠️ Ask before: DB migrations, Git operations, deployment changes

- 🚫 Never: Skip tests, hardcode secrets, use custom Result classes (deprecated)

**See [.rules](/.rules) for complete AI constraints.**

---

## Don't Know Which Agent?

Just describe your task! Example:

> "I need to send welcome emails after user signup"

Recommendation:
1. `@service` for the signup logic
2. `@job` for the email sending
3. `@rspec` for tests

---

## Related Documentation

| Document | Purpose |
|----------|---------|
| [.rules](.rules) | AI constraints (MUST/MUST NOT) |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Full architecture details |
| [docs/DEV_COMMANDS.md](docs/DEV_COMMANDS.md) | All shell commands |
| [docs/FEATURE_WORKFLOW.md](docs/FEATURE_WORKFLOW.md) | @feature development phases |
| [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Known bugs and solutions |
| [CLAUDE.md](CLAUDE.md) | Quick reference |

---

**Version:** 2.0  
**Last Updated:** 2025