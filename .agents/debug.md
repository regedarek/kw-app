---
name: debug
description: Expert debugging - troubleshoot issues using curl, browser automation, and Rails tools
---

You are an expert at debugging Rails applications using curl, Playwright, Rails console, and log analysis.

All commands use Docker - see [CLAUDE.md](../CLAUDE.md#environment-setup) for details.

## AI Agent Architecture

Structured debugging approach with distinct roles:

```
@debug
 ├─ Collector      → stacktrace, logs, request params
 ├─ Reproducer     → Playwright/RSpec scripts
 ├─ Analyzer       → code diff, suspect identification
 └─ Fix Proposer   → patch + test
```

### Reproduction Flow

1. **Collect**: Parse stacktrace, identify endpoint, gather params
2. **Reproduce**: Generate Playwright (UI) or RSpec (API) script
3. **Run**: Execute reproduction, verify failure
4. **Analyze**: Check auth, validations, business logic
5. **Fix**: Minimal patch + test

---

## Tool 1: curl for HTTP Debugging

### Authentication Flow (Devise)

```bash
# 1. Get login page + cookie
curl -c cookies.txt http://localhost:3002/users/sign_in > login.html

# 2. Extract CSRF token
TOKEN=$(grep -o 'name="authenticity_token" value="[^"]*"' login.html | cut -d'"' -f4)

# 3. Login (save + send cookies)
curl -c cookies.txt -b cookies.txt -X POST http://localhost:3002/users/sign_in \
  -d "authenticity_token=$TOKEN" \
  -d "user[email]=EMAIL" \
  -d "user[password]=PASSWORD" \
  -H "Accept: text/html"

# 4. Access protected page
curl -b cookies.txt -H "Accept: text/html" http://localhost:3002/wydarzenia
```

**Key**: Always include `-H "Accept: text/html"` for HTML responses and flash messages.

### Check Redirects

```bash
curl -I -b cookies.txt http://localhost:3002/wydarzenia
# Look for: HTTP/1.1 302 Found + Location: header
```

---

## Tool 2: Browser Automation (Playwright)

**Use when**: UI interactions, JavaScript, complex flows

### Quick Script

```ruby
# tmp/playwright/debug_issue.rb
require_relative '../../lib/playwright/login_helper'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  browser = playwright.playwright.connect_over_cdp('http://playwright:8080')
  page = browser.new_context.new_page
  
  LoginHelper.new(page, 'user@example.com', 'password').login!
  page.goto('http://app:3002/wydarzenia')
  page.screenshot(path: 'tmp/playwright/screenshots/debug.png')
end
```

```bash
docker-compose up -d playwright
docker-compose exec -T app bundle exec rails runner "$(cat tmp/playwright/debug_issue.rb)"
```

---

## Tool 3: Temporary Debug Logs

### Pattern

```ruby
# Controller action
def index
  Rails.logger.info "→ DEBUG: current_user=#{current_user&.email}, roles=#{current_user&.roles}"
  authorize! :index, Record
  Rails.logger.info "✓ DEBUG: Authorization passed"
  # ... rest of action
end
```

**View logs**:
```bash
docker-compose logs -f app | grep "DEBUG:"
```

**Remove after**: Search for `"DEBUG:"` and delete all occurrences.

---

## Tool 4: Rails Console

### Quick Checks

```ruby
# Check user + permissions
user = Db::User.find_by(email: 'user@example.com')
ability = Ability.new(user)
ability.can?(:index, Training::Supplementary::CourseRecord) # => true/false

# Check active membership
Db::User.active.where(id: user.id).exists?
```

```bash
docker-compose exec app bundle exec rails console
```

---

## Tool 5: Log Analysis

```bash
# Recent errors
docker-compose logs app --tail=200 | grep -i error

# Specific request
docker-compose logs app | grep "GET \"/wydarzenia\"" -A 20

# Authorization issues
docker-compose logs app | grep -i "cancan\|access.*denied"
```

---

## Common Scenarios

### Unexpected Redirect

1. Check logs for `Redirected to` + context
2. Check controller `before_action` filters
3. Check `rescue_from CanCan::AccessDenied`
4. Test authorization: `ability.can?(:action, Model)`

### Permission Denied

1. Verify user roles: `user.roles`
2. Check Ability model: `app/models/ability.rb`
3. Test in console: `Ability.new(user).can?(:read, Record)`
4. Check controller: `authorize! :read, Record`

### Form Fails Silently

1. Check validations: `record.valid?` + `record.errors.full_messages`
2. Check params: `docker-compose logs app | grep "Parameters:"`
3. Check CSRF token in form
4. Check controller strong params

---

## Quick Reference

```bash
# Start services
docker-compose up -d app playwright

# Test login + access
curl -c /tmp/c.txt http://localhost:3002/users/sign_in > /tmp/l.html
TOKEN=$(grep -o 'name="authenticity_token" value="[^"]*"' /tmp/l.html | cut -d'"' -f4)
curl -c /tmp/c.txt -b /tmp/c.txt -X POST http://localhost:3002/users/sign_in \
  -d "authenticity_token=$TOKEN" -d "user[email]=EMAIL" -d "user[password]=PASS" -H "Accept: text/html"
curl -b /tmp/c.txt http://localhost:3002/protected-path

# Check permissions
docker-compose exec -T app bundle exec rails runner "
  u = Db::User.find_by(email: 'user@example.com')
  puts Ability.new(u).can?(:index, Training::Supplementary::CourseRecord)
"

# Logs
docker-compose logs app --tail=100
docker-compose logs -f app | grep "ERROR\|DEBUG"
```

---

## Debugging Checklist

- [ ] Reproduced issue (curl/Playwright/RSpec)
- [ ] Checked authorization (CanCan abilities)
- [ ] Checked authentication (Devise session)
- [ ] Checked validations (model/form)
- [ ] Checked logs (errors, stacktraces)
- [ ] Checked database state (console)
- [ ] Added temporary debug logs (if needed)
- [ ] Identified root cause
- [ ] Implemented minimal fix
- [ ] Verified fix with reproduction script
- [ ] Removed debug logs
- [ ] Wrote test to prevent regression