# Feature Development Workflow

> Step-by-step guide for developing new features in kw-app using the `@feature` workflow.

---

## Table of Contents

1. [Overview](#overview)
2. [Phase 1: Requirements Gathering](#phase-1-requirements-gathering)
3. [Phase 2: Solution Proposal](#phase-2-solution-proposal)
4. [Phase 3: Implementation](#phase-3-implementation)
5. [Phase 4: Testing & Quality Gates](#phase-4-testing--quality-gates)
6. [Phase 5: Review & Completion](#phase-5-review--completion)
7. [Example Walkthrough](#example-walkthrough)
8. [Quick Reference](#quick-reference)

---

## Overview

When a user mentions `@feature` or requests a new feature, the AI assistant MUST follow this structured workflow. This ensures:

- Complete understanding of requirements before coding
- User approval at each stage
- Proper test coverage
- Consistent architecture

### Workflow Summary

```
Phase 1: Requirements   →  Ask questions ONE BY ONE
Phase 2: Proposal       →  Present solution, wait for approval
Phase 3: Implementation →  TDD: Write tests first, then code
Phase 4: Quality Gates  →  Run tests, lint, verify
Phase 5: Review         →  Final check before completion
```

### Critical Rules

1. **Ask questions ONE BY ONE** — Wait for each answer
2. **Propose before implementing** — Get explicit approval
3. **Tests before code** — TDD workflow
4. **Never skip phases** — Even for "simple" features

---

## Phase 1: Requirements Gathering

### Purpose

Fully understand what the user wants before proposing any solution.

### Process

Ask these questions **ONE AT A TIME**, waiting for each answer:

#### Question Set A: Core Requirements

1. **User Story**: "What should users be able to do? (e.g., 'Users can comment on blog posts')"

2. **Actors**: "Who will use this feature? (e.g., all users, admins only, specific roles)"

3. **Acceptance Criteria**: "How will we know it's working? What are the success conditions?"

#### Question Set B: Technical Scope

4. **Data Requirements**: "What data needs to be stored? (fields, relationships)"

5. **UI/UX**: "How should users interact with this? (form, list, button, API only)"

6. **Existing Code**: "Does this extend existing features or is it completely new?"

#### Question Set C: Edge Cases

7. **Validation**: "What rules should the input follow? (required fields, formats, limits)"

8. **Authorization**: "Who can perform each action? (create, read, update, delete)"

9. **Error Scenarios**: "What should happen when things go wrong?"

### Output

After gathering answers, summarize understanding:

```markdown
## Requirements Summary

**User Story**: [What users can do]
**Actors**: [Who uses it]
**Data Model**: [Fields and relationships]
**Validations**: [Input rules]
**Authorization**: [Permission rules]
**Edge Cases**: [Error handling]

Is this understanding correct? (yes/no)
```

Wait for explicit confirmation before proceeding.

---

## Phase 2: Solution Proposal

### Purpose

Present a concrete implementation plan for user approval.

### Process

Create a detailed proposal including:

1. **Technical Approach** — High-level design decisions
2. **Files to Create/Modify** — Specific paths
3. **Database Changes** — Migrations needed
4. **Component List** — Each component with responsibility
5. **Implementation Order** — Step-by-step sequence

### Proposal Template

```markdown
## Feature: [Feature Name]

### Technical Approach

[High-level description of how this will be implemented]

### Database Changes

- [ ] Migration: `CreateXxx` — [description]
- [ ] Migration: `AddYyyToZzz` — [description]

### Components to Create

| Component | Path | Responsibility |
|-----------|------|----------------|
| Model | `app/models/db/xxx.rb` | [description] |
| Operation | `app/components/xxx/operation/create.rb` | [description] |
| Contract | `app/components/xxx/contract/create.rb` | [description] |
| Controller | `app/controllers/xxx_controller.rb` | [description] |
| Job | `app/jobs/xxx_job.rb` | [description] |

### Tests to Write

| Spec | Path | Coverage |
|------|------|----------|
| Model | `spec/models/db/xxx_spec.rb` | Associations, validations, scopes |
| Operation | `spec/components/xxx/operation/create_spec.rb` | Success/failure paths |
| Request | `spec/requests/xxx_spec.rb` | HTTP integration |

### Implementation Order

1. Generate migration and run
2. Create model with validations
3. Write model specs (should pass)
4. Write operation specs (should fail)
5. Create operation (specs should pass)
6. Write request specs (should fail)
7. Create controller (specs should pass)
8. Run full test suite
9. Manual testing

### Risks & Considerations

- [Potential issues]
- [Performance concerns]
- [Security considerations]

---

**Do you approve this plan? (yes/no/changes needed)**
```

Wait for explicit approval before proceeding.

---

## Phase 3: Implementation

### Purpose

Build the feature using TDD (Test-Driven Development).

### Process

Follow the implementation order from the approved proposal:

#### Step 1: Database Setup

```bash
# Generate migration
docker-compose exec -T app bundle exec rails g migration CreateXxx field:type

# Run migration
docker-compose exec -T app bundle exec rake db:migrate

# Verify
docker-compose exec -T app bundle exec rake db:migrate:status
```

#### Step 2: Model Layer

1. Create model file (`app/models/db/xxx.rb`)
2. Define associations, validations, scopes
3. Write model specs
4. Run specs: `docker-compose exec -T app bundle exec rspec spec/models/db/xxx_spec.rb`

#### Step 3: Operation Layer (TDD)

1. **Write failing operation spec first**
2. Create operation file
3. Run spec until it passes
4. Refactor if needed

```ruby
# spec/components/xxx/operation/create_spec.rb
RSpec.describe Xxx::Operation::Create do
  describe '#call' do
    context 'with valid params' do
      it 'returns Success' do
        # Write expectations
      end
    end
    
    context 'with invalid params' do
      it 'returns Failure' do
        # Write expectations
      end
    end
  end
end
```

#### Step 4: Controller Layer

1. Write failing request specs
2. Create controller
3. Add routes
4. Run specs until passing

#### Step 5: Background Jobs (if needed)

1. Write job specs
2. Create job class
3. Integrate with operation

### Code Templates

Use templates from `templates/` directory. Key patterns:

- **Operation**: `include Dry::Monads[:result, :do]`
- **Controller**: Pattern matching on `Success`/`Failure`
- **Model**: Thin, no business logic

---

## Phase 4: Testing & Quality Gates

### Purpose

Ensure code quality and correctness before completion.

### Checklist

#### Tests

- [ ] All new specs pass
- [ ] Full test suite passes
- [ ] Edge cases covered
- [ ] Error scenarios tested

```bash
# Run all tests
docker-compose exec -T app bundle exec rspec

# Run specific feature tests
docker-compose exec -T app bundle exec rspec spec/components/xxx/
docker-compose exec -T app bundle exec rspec spec/requests/xxx_spec.rb
```

#### Code Quality

- [ ] RuboCop passes

```bash
docker-compose exec -T app bundle exec rubocop app/models/db/xxx.rb
docker-compose exec -T app bundle exec rubocop app/components/xxx/
docker-compose exec -T app bundle exec rubocop app/controllers/xxx_controller.rb
```

- [ ] No security warnings

```bash
docker-compose exec -T app bundle exec brakeman
```

#### Architecture

- [ ] Operations use dry-monads
- [ ] Controllers are thin
- [ ] Models are thin
- [ ] Jobs pass IDs, not objects

#### Manual Verification

- [ ] Feature works as expected in browser/console
- [ ] Error handling works correctly
- [ ] Authorization enforced

---

## Phase 5: Review & Completion

### Purpose

Final verification before marking the feature complete.

### Completion Checklist

```markdown
## Feature Completion: [Feature Name]

### Tests
- [ ] All specs pass: `docker-compose exec -T app bundle exec rspec`
- [ ] Test coverage adequate

### Code Quality
- [ ] RuboCop passes
- [ ] Brakeman passes

### Architecture
- [ ] dry-monads used in operations
- [ ] Controllers delegate to operations
- [ ] Models are thin

### Documentation
- [ ] Code comments where needed
- [ ] KNOWN_ISSUES.md updated (if new pattern discovered)

### Ready for Review
- [ ] All changes are saved
- [ ] Git diff reviewed
```

### Completion Statement

```
Feature [Name] is complete:
- ✅ [N] specs passing
- ✅ All quality gates passed
- ✅ Manual testing verified
- ✅ Ready for commit

Would you like me to summarize the changes or make any adjustments?
```

---

## Example Walkthrough

### User Request

> "@feature Add commenting to blog posts"

### Phase 1: Requirements Gathering

**AI**: "What should users be able to do with comments?"

**User**: "Users can add comments to posts. Authors can delete their own comments."

**AI**: "Who can add comments?"

**User**: "Only logged-in users."

**AI**: "What fields should a comment have?"

**User**: "Just the body text. Keep it simple."

*[Continue with remaining questions...]*

**AI Summary**:
```
## Requirements Summary

**User Story**: Logged-in users can comment on posts
**Actors**: Authenticated users
**Data Model**: Comment (body:text, user_id, post_id)
**Validations**: Body required, 1-1000 characters
**Authorization**: Any user creates, only author deletes
**Edge Cases**: Post not found, user not logged in

Is this understanding correct?
```

### Phase 2: Proposal

*[AI presents detailed proposal with components, tests, order...]*

**User**: "Approved"

### Phase 3-4: Implementation

*[AI creates code TDD-style, runs tests...]*

### Phase 5: Completion

```
Feature "Post Comments" is complete:
- ✅ 12 specs passing
- ✅ RuboCop clean
- ✅ Manual testing verified

Files created:
- db/migrate/xxx_create_comments.rb
- app/models/db/comment.rb
- app/components/comments/operation/create.rb
- app/components/comments/operation/delete.rb
- app/controllers/comments_controller.rb
- spec/models/db/comment_spec.rb
- spec/components/comments/operation/create_spec.rb
- spec/components/comments/operation/delete_spec.rb
- spec/requests/comments_spec.rb
```

---

## Quick Reference

### Phase Summary

| Phase | Action | Wait For |
|-------|--------|----------|
| 1. Requirements | Ask questions one by one | Each answer |
| 2. Proposal | Present detailed plan | Explicit approval |
| 3. Implementation | TDD: test → code → refactor | N/A |
| 4. Quality Gates | Run tests, lint, verify | All green |
| 5. Completion | Final checklist | User confirmation |

### Commands

```bash
# Testing
docker-compose exec -T app bundle exec rspec

# Linting
docker-compose exec -T app bundle exec rubocop -a

# Security
docker-compose exec -T app bundle exec brakeman

# Console
docker-compose exec app bundle exec rails console
```

### Templates Location

- Operation: `templates/operation.rb`
- Controller: `templates/controller.rb`
- Model: `templates/model.rb`
- Spec: `templates/*_spec.rb`

---

## Related Documentation

- **[.rules](../.rules)** — AI constraints
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Full architecture details
- **[DEV_COMMANDS.md](DEV_COMMANDS.md)** — Shell commands
- **[AGENTS.md](../AGENTS.md)** — Available agents
- **[@feature-planner](../.agents/feature-planner.md)** — Planning agent details

---

**Version:** 1.0  
**Last Updated:** 2025