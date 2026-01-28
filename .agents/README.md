# Agents Directory

> Specialized agents for kw-app development tasks.

**For agent routing and selection, see [AGENTS.md](../AGENTS.md) (root level).**

---

## Directory Contents

### Agent Files

| Agent | Purpose |
|-------|---------|
| `console.md` | Rails console script execution |
| `model.md` | ActiveRecord model creation/modification |
| `service.md` | Service objects with dry-monads |
| `rspec.md` | Testing with RSpec |
| `debug.md` | Issue troubleshooting |
| `browser.md` | Playwright browser automation |
| `job.md` | Sidekiq background jobs |
| `refactor.md` | Code refactoring |
| `feature-planner.md` | Feature planning and breakdown |
| `review.md` | Code review |
| `security.md` | Security auditing |

### Skills Directory

Deep-dive knowledge modules in `skills/`:

- `activerecord-patterns/` — ActiveRecord best practices
- `dry-monads-patterns/` — Success/Failure monad patterns
- `kamal-deployment/` — Zero-downtime deployment
- `performance-optimization/` — N+1 prevention, caching
- `rails-service-object/` — Service object architecture
- `testing-standards/` — RSpec + FactoryBot patterns

---

## Documentation Structure

This project follows a structured documentation pattern:

| File | Purpose |
|------|---------|
| `.rules` | AI constraints (MUST/MUST NOT) |
| `AGENTS.md` | Agent inventory and routing |
| `CLAUDE.md` | Quick reference |
| `docs/ARCHITECTURE.md` | Full architecture details |
| `docs/DEV_COMMANDS.md` | All shell commands |
| `docs/FEATURE_WORKFLOW.md` | @feature development phases |
| `docs/KNOWN_ISSUES.md` | Known bugs and solutions |
| `templates/` | Code templates |
| `.zed/tasks.json` | Zed IDE task launchers |

---

## Agent Design Principles

All agents follow these principles:

1. **Reference, don't duplicate** — Point to docs instead of repeating content
2. **Commands from docs** — All shell commands live in `docs/DEV_COMMANDS.md`
3. **Templates from templates/** — Code patterns live in `templates/`
4. **Three-tier boundaries** — ✅ Always, ⚠️ Ask first, 🚫 Never

---

## Quick Links

- **[Agent Selection Guide](../AGENTS.md)** — Which agent for which task
- **[AI Rules](../.rules)** — Constraints and requirements
- **[Commands Reference](../docs/DEV_COMMANDS.md)** — All shell commands
- **[Architecture](../docs/ARCHITECTURE.md)** — Code patterns and structure

---

**Version:** 2.0  
**Last Updated:** 2025