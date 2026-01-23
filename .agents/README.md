# Agent Quick Reference

> **Need help choosing an agent?** This guide shows which specialist to call for common tasks.

---

## 🎯 Quick Decision Tree

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

## 📚 Available Agents

### 🔨 Implementation Agents

| Agent | Use When | Quick Example |
|-------|----------|---------------|
| **[@console](.agents/console.md)** | Need Rails console script | "Return all active users as JSON" |
| **[@model](.agents/model.md)** | Creating/modifying ActiveRecord models | "Add User model with email validation" |
| **[@service](.agents/service.md)** | Creating business logic services | "Create payment processing service" |
| **[@job](.agents/job.md)** | Creating background jobs | "Create email notification job" |

### 🧪 Testing & Quality

| Agent | Use When | Quick Example |
|-------|----------|---------------|
| **[@rspec](.agents/rspec.md)** | Writing or running tests | "Test User authentication flow" |
| **[@debug](.agents/debug.md)** | Fixing bugs or investigating issues | "Fix login redirect loop" |
| **[@browser](.agents/browser.md)** | Browser automation/testing | "Test form submission flow" |
| **[@review](.agents/review.md)** | Code review before merge | "Review my changes for issues" |
| **[@security](.agents/security.md)** | Security audit | "Check for security vulnerabilities" |

### 🔧 Maintenance

| Agent | Use When | Quick Example |
|-------|----------|---------------|
| **[@refactor](.agents/refactor.md)** | Improving code structure | "Extract service from controller" |

### 🎯 Planning & Orchestration

| Agent | Use When | Quick Example |
|-------|----------|---------------|
| **[@feature-planner](.agents/feature-planner.md)** | Planning new features | "Plan user authentication feature" |

---

## 🚀 Common Workflows

### Adding a New Feature (Full TDD)
```
1. @feature-planner analyze requirements for blog comments
2. @rspec write failing test for Comment model
3. @model create Comment model
4. @rspec write failing test for Comments::CreateService
5. @service implement Comments::CreateService
6. @rspec run all tests
7. @review check implementation
8. @refactor improve if needed
```

### Quick Script Execution
```
1. @console write script to update user statuses
   (Automatically writes + executes + shows results)
```

### Debugging Production Issue
```
1. @debug investigate error: "undefined method 'total' for nil"
2. @rspec add regression test
3. @review verify fix
```

### Background Job Setup
```
1. @job create SendWelcomeEmailJob
2. @rspec write tests for the job
3. @console test job execution manually
```

---

## 📖 Skills Library

Deep-dive knowledge modules for specific patterns (see [skills/](skills/) directory):

- **[activerecord-patterns](skills/activerecord-patterns/SKILL.md)** - ActiveRecord best practices and patterns
- **[dry-monads-patterns](skills/dry-monads-patterns/SKILL.md)** - Success/Failure monad patterns (kw-app specific)
- **[kamal-deployment](skills/kamal-deployment/SKILL.md)** - Zero-downtime deployment patterns
- **[testing-standards](skills/testing-standards/SKILL.md)** - RSpec + FactoryBot best practices
- **[rails-service-object](skills/rails-service-object/SKILL.md)** - Service object architecture
- **[performance-optimization](skills/performance-optimization/SKILL.md)** - N+1 prevention, caching

---

## 🎓 Agent Design Philosophy

All agents in this project follow these principles:

### ✅ What Makes Our Agents Effective

1. **Commands Early** - Executable commands right at the top
2. **Project Context** - Know the exact tech stack (Ruby 3.2.2, Rails 7.0.8, dry-monads)
3. **Three-Tier Boundaries**:
   - ✅ **Always** - Must do
   - ⚠️ **Ask first** - Requires confirmation  
   - 🚫 **Never** - Hard limits
4. **Code Examples** - Real good/bad patterns from this project
5. **Skills Integration** - Reference Skills Library for deep patterns

### 🔗 Single Source of Truth

- **Policy & Cross-cutting Rules** → [CLAUDE.md](../CLAUDE.md)
- **Domain-Specific Patterns** → Individual agent files
- **Deep-Dive Knowledge** → [Skills Library](skills/)

---

## 🆘 Don't Know Which Agent?

**Just describe your task!** Example:

> "I need to send welcome emails after user signup"

The system will recommend:
1. `@service` for the signup logic  
2. `@job` for the email sending
3. `@rspec` for tests

---

## 🔧 Project-Specific Rules

**All agents must follow kw-app conventions:**

- ✅ Use Docker for ALL app commands (tests, rake, console)
- ✅ Use dry-monads for service objects (`Success(value)` / `Failure(error)`)
- ✅ Write tests before marking work complete
- ⚠️ Ask before: DB migrations, Git operations, deployment changes
- 🚫 Never: Skip tests, hardcode secrets, use custom Result classes

**See [CLAUDE.md](../CLAUDE.md) for complete guidelines.**

---

## 📚 Additional Resources

- **Main Guidelines**: [CLAUDE.md](../CLAUDE.md)
- **Known Issues**: [docs/KNOWN_ISSUES.md](../docs/KNOWN_ISSUES.md) ⚠️ Check first when debugging!
- **Cheat Sheet**: [CHEATSHEET.md](CHEATSHEET.md) - Common commands reference

---

**Version**: 2.0  
**Last Updated**: 2024-01  
**Maintained By**: kw-app team