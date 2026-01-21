# Rails AI Agents for kw-app

This directory contains specialized AI agents for Zed editor to provide context-aware Rails development assistance.

## What Are AI Agents?

AI agents are markdown files that give your AI assistant (like Claude in Zed) specialized knowledge about specific aspects of your Rails application. They help the AI understand:

- Your project structure and conventions
- How to run tests and commands in Docker
- Best practices for Rails patterns
- When to use different architectural approaches

## Available Agents

### 🧪 `rspec-agent.md`
**Expert QA engineer in RSpec for Rails 8.1 with Hotwire**

Use this agent when:
- Writing or updating tests
- Debugging failing specs
- Creating factories
- Testing Turbo/Stimulus features

Example usage in Zed:
```
@rspec-agent write tests for the User model
@rspec-agent add a system test for user registration
```

### 🔧 `service-agent.md`
**Expert Rails Service Objects**

Use this agent when:
- Creating business logic that involves multiple models
- Implementing complex workflows
- Building features with transactions
- Extracting logic from controllers/models

Example usage in Zed:
```
@service-agent create a service to process entity submissions
@service-agent add a service for calculating entity ratings
```

## How to Use Agents in Zed

### 1. Invoke an Agent
In Zed's assistant panel, type `@` followed by the agent name:

```
@rspec-agent <your request>
@service-agent <your request>
```

### 2. Agent Context
Agents automatically have context about:
- Your Docker setup
- How to run commands with `docker compose exec -T app`
- Your project structure
- RSpec configuration
- Rails conventions

### 3. Examples

**Writing Tests:**
```
@rspec-agent write model specs for the Submission model with validations and associations
```

**Creating Services:**
```
@service-agent create a service to handle entity creation with notifications
```

**Running Tests:**
```
@rspec-agent run the tests for entities and show me the output
```

## Adding More Agents

Want to add more agents? Download them from:
https://github.com/ThibautBaissac/rails_ai_agents

### Recommended Agents to Add:

**Standard Rails Agents:**
- `model-agent.md` - ActiveRecord model design
- `controller-agent.md` - RESTful controllers
- `query-agent.md` - Complex query objects
- `turbo-agent.md` - Hotwire/Turbo patterns
- `stimulus-agent.md` - Stimulus controllers
- `review-agent.md` - Code quality analysis

**Feature Planning:**
- `feature-planner-agent.md` - Break features into tasks
- `tdd-red-agent.md` - Write failing tests first

### How to Add:

1. Download the agent file from the repository
2. Save it to `kw-app/.agents/`
3. Customize Docker commands if needed
4. Start using with `@agent-name`

## Customizing for kw-app

All agents in this directory have been customized for kw-app:

✅ Docker commands use `docker compose exec -T app` for non-interactive mode
✅ Interactive commands (console, bash) use `docker compose exec app`
✅ All paths reference the kw-app project structure
✅ Agents understand your RSpec setup
✅ Agents know about PostgreSQL, Redis, Sidekiq

## Tips

1. **Use specific agents** - They have deeper context than general AI
2. **Check Docker containers** - Agents assume containers are running
3. **Review generated code** - Agents provide starting points, not final solutions
4. **Iterate** - Ask follow-up questions to refine the output

## Project-Specific Context

These agents know about:
- Docker Compose setup (app, postgres, redis, sidekiq containers)
- Port mappings (5433 for PostgreSQL, 6380 for Redis)
- RSpec + FactoryBot testing setup
- CarrierWave for file uploads
- Kamal for deployment
- Your CLAUDE.md guidelines

## Resources

- [Rails AI Agents Repository](https://github.com/ThibautBaissac/rails_ai_agents)
- [Zed AI Documentation](https://zed.dev/docs/assistant)
- [GitHub: How to Write Great Agents](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)