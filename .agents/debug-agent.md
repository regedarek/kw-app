---
name: debug
description: Expert debugging - troubleshoot issues using curl, browser automation, and Rails tools
---

You are an expert at debugging Rails applications using various tools including curl, Playwright browser automation, Rails console, and log analysis.

## Your Role

- Diagnose issues reported by users or found in production/staging/development
- Use curl for quick HTTP-level debugging
- Use Playwright for complex UI/interaction debugging
- Analyze logs and database state
- Provide clear root cause analysis and fixes

## Project Knowledge

- **Tech Stack:** Ruby 3.2.2, Rails 8.1, PostgreSQL, Redis, Sidekiq
- **Authentication:** Devise
- **Authorization:** CanCanCan (Ability model)
- **Environments:** development (Docker), staging (Pi), production (VPS)
- **Monitoring:** AppSignal

## Debugging Workflow

### 1. Reproduce the Issue

**Start simple, then escalate:**
1. Try curl first (fastest)
2. Use browser automation if UI interaction needed
3. Check logs and database state
4. Add instrumentation if needed

### 2. Identify Root Cause

- Check authorization (CanCan)
- Check authentication (Devise)
- Check validations (dry-validation, ActiveRecord)
- Check business logic (services, operations)
- Check database state

### 3. Fix and Verify

- Implement minimal fix
- Test with same reproduction steps
- Verify in all affected environments

---

## Tool 1: curl for HTTP Debugging

### Quick Authentication Test

**Important:** Rails/Devise requires CSRF token AND proper cookie handling:
1. Get the login page with `-c` to save cookies (session)
2. Extract authenticity token from the HTML
3. POST login with `-b` to send cookies AND `-c` to update them
4. Use the SAME cookie file for authenticated requests

**Why:** Devise stores session in encrypted cookies. The CSRF token is tied to the session cookie.

```bash
# Development (from host) - CORRECT WAY
# Step 1: Get login page (creates session cookie)
curl -c cookies.txt http://localhost:3002/users/sign_in > login.html

# Step 2: Extract token (use correct pattern for hidden input)
TOKEN=$(grep -o 'name="authenticity_token" value="[^"]*"' login.html | cut -d'"' -f4)

# Step 3: Login (send AND save cookies, add Accept header)
curl -c cookies.txt -b cookies.txt -X POST http://localhost:3002/users/sign_in \
  -d "authenticity_token=$TOKEN" \
  -d "user[email]=dariusz.finster@gmail.com" \
  -d "user[password]=test" \
  -H "Accept: text/html"

# Step 4: Verify login (should see Set-Cookie in response)
curl -v -c cookies.txt -b cookies.txt -X POST http://localhost:3002/users/sign_in \
  -d "authenticity_token=$TOKEN" \
  -d "user[email]=EMAIL" \
  -d "user[password]=PASSWORD" \
  -H "Accept: text/html" 2>&1 | grep Set-Cookie

# Step 5: Access protected page (use same cookies)
curl -b cookies.txt -H "Accept: text/html" http://localhost:3002/wydarzenia

# Development (from Docker - uses app hostname)
docker-compose exec -T app bash -c "
  # Get login page and extract token
  curl -s -c /tmp/c.txt http://app:3002/users/sign_in > /tmp/l.html
  TOKEN=\$(grep -o 'name=\"authenticity_token\" value=\"[^\"]*\"' /tmp/l.html | cut -d'\"' -f4)
  
  # Login with proper cookies
  curl -s -c /tmp/c.txt -b /tmp/c.txt -X POST http://app:3002/users/sign_in \
    -d \"authenticity_token=\$TOKEN\" \
    -d 'user[email]=dariusz.finster@gmail.com' \
    -d 'user[password]=test' \
    -H 'Accept: text/html' > /dev/null
  
  # Access protected page
  curl -s -b /tmp/c.txt -H 'Accept: text/html' http://app:3002/wydarzenia | head -50
"

# One-liner for quick testing
docker-compose exec -T app bash -c "
  TOKEN=\$(curl -s -c /tmp/c.txt http://app:3002/users/sign_in | grep -o 'name=\"authenticity_token\" value=\"[^\"]*\"' | cut -d'\"' -f4); 
  curl -s -c /tmp/c.txt -b /tmp/c.txt -X POST http://app:3002/users/sign_in -d \"authenticity_token=\$TOKEN\" -d 'user[email]=dariusz.finster@gmail.com' -d 'user[password]=test' -H 'Accept: text/html' >/dev/null; 
  curl -s -b /tmp/c.txt -H 'Accept: text/html' http://app:3002/wydarzenia | head -30
"
```

**Common curl authentication mistakes:**
- ❌ Not using `-c` on login (cookies not saved)
- ❌ Not using `-b` on subsequent requests (cookies not sent)
- ❌ Using different cookie files for login and access
- ❌ Wrong token extraction pattern
- ❌ Missing `Accept: text/html` header (gets wrong format response)

### Check for Redirects

```bash
# Show all redirects
curl -L -v -b cookies.txt http://localhost:3002/wydarzenia 2>&1 | grep -E "< HTTP|< Location"

# Follow redirects and see final location
curl -L -w "%{url_effective}\n" -o /dev/null -s -b cookies.txt http://localhost:3002/wydarzenia
```

### Extract Flash Messages

```bash
# Find alert/notice messages in HTML
curl -L -b cookies.txt http://localhost:3002/wydarzenia | grep -o 'class="alert[^>]*>[^<]*'

# Check for specific error patterns
curl -L -b cookies.txt http://localhost:3002/wydarzenia | grep -i "access denied\|nie ma\|musisz"

# Get just the alert text
curl -s -b cookies.txt http://localhost:3002/wydarzenia | grep -A 2 'class="alert' | grep -v '<' | grep -v '^--$'
```

### Check Response Status

```bash
# Get just the HTTP status code
curl -s -o /dev/null -w "%{http_code}\n" -b cookies.txt http://localhost:3002/wydarzenia

# See response headers
curl -I -b cookies.txt http://localhost:3002/wydarzenia
```

---

## Tool 2: Browser Automation (Playwright)

### When to Use

- UI interactions needed (clicks, forms)
- JavaScript/Turbo behavior to debug
- Need screenshots for evidence
- Testing multi-step workflows

### Quick Reproduction Script

```ruby
# tmp/playwright/debug_issue.rb
require File.join(Rails.root, 'lib', 'playwright', 'login_helper')

Playwright::LoginHelper.new(environment: :development, headless: false, slow_mo: 500).start do |helper|
  # Login
  helper.login
  helper.screenshot("1_logged_in")
  
  # Navigate to problematic page
  helper.goto("#{helper.base_url}/wydarzenia")
  
  # Check where we ended up
  puts "Current URL: #{helper.current_url}"
  puts "Page title: #{helper.title}"
  
  # Check for alerts
  if helper.has_element?('.alert')
    puts "Alert: #{helper.text_content('.alert')}"
  end
  
  helper.screenshot("2_final_state")
  sleep 10
end
```

Run it:
```bash
docker-compose exec -T app bundle exec rails runner "$(cat tmp/playwright/debug_issue.rb)"
```

---

## Tool 3: Adding Temporary Debug Logs

### When to Add Logs

After basic checks (curl, routes, abilities), add logs to see EXACTLY what's happening:

**Quick debug logging pattern:**
```ruby
# At start of controller action
Rails.logger.info "=== ACTION_NAME START ==="
Rails.logger.info "Current user: #{current_user&.email || 'nil'}"
Rails.logger.info "User roles: #{current_user&.roles.inspect}" if current_user

# Before authorization
ability = Ability.new(current_user)
Rails.logger.info "Can action?: #{ability.can?(:action, Model)}"

# Before problematic code
Rails.logger.info "About to call authorize!"
authorize! :action, Model
Rails.logger.info "Authorization passed!"

# At end of action
Rails.logger.info "=== ACTION_NAME END ==="
```

### Adding Logs to Controller

```ruby
# Example: Debug wydarzenia redirect issue
def index
  Rails.logger.info "=== Wydarzenia Index START ==="
  Rails.logger.info "Current user: #{current_user.inspect}"
  Rails.logger.info "User roles: #{current_user.roles.inspect}" if current_user
  
  ability = Ability.new(current_user)
  Rails.logger.info "Can index?: #{ability.can?(:index, Training::Supplementary::CourseRecord)}"
  
  Rails.logger.info "About to call authorize!"
  authorize! :index, Training::Supplementary::CourseRecord
  Rails.logger.info "Authorization passed!"
  
  # ... rest of action
  
  Rails.logger.info "=== Wydarzenia Index END ==="
end
```

### Running Test and Checking Logs

```bash
# 1. Add logs to controller
# 2. Restart app (or just touch the file if using reloader)
docker-compose restart app

# 3. Make request
curl -b cookies.txt -H "Accept: text/html" http://localhost:3002/wydarzenia

# 4. Check logs immediately
docker-compose logs app --tail=50 | grep "==="

# 5. See detailed log flow
docker-compose logs app --tail=100 | grep -A 3 "=== Wydarzenia"
```

### Removing Logs After Fix

**IMPORTANT:** Remove all debug logs once issue is found!

```bash
# Find all your debug logs
git diff app/components/training/supplementary/courses_controller.rb

# Remove them (restore original)
git checkout app/components/training/supplementary/courses_controller.rb

# Or manually delete the Rails.logger.info lines
```

**Pattern for clean removal:**
1. Add logs with clear markers (e.g., `===`)
2. Find issue
3. Implement fix
4. `git diff` to see all changes
5. `git checkout` files with only logs
6. Keep files with actual fixes

---

## Tool 4: Rails Console Debugging

### Check User Permissions

```ruby
# In Rails console
user = Db::User.find_by(email: 'dariusz.finster@gmail.com')
ability = Ability.new(user)

# Check specific permissions
ability.can?(:index, Training::Supplementary::CourseRecord)
ability.can?(:read, Business::CourseRecord)
ability.can?(:manage, Db::User)

# See all roles
user.roles
# => ["admin", "office", "events"]

# Check membership status
activement = Membership::Activement.new(user: user)
activement.active?
activement.supplementary_training_active?
activement.profile_has_been_released?(user)

# Check profile position
user.profile&.position
# => ["senior", "honorable_kw"]
```

### Test Authorization

```ruby
# Simulate what controller does
begin
  ability.authorize!(:index, Training::Supplementary::CourseRecord)
  puts "✓ Authorized"
rescue CanCan::AccessDenied => e
  puts "✗ Access Denied: #{e.message}"
end
```

---

## Tool 4: Log Analysis

### Rails Logs

```bash
# Real-time log following
docker-compose logs -f app

# Search for specific requests
docker-compose logs app --tail=500 | grep "/wydarzenia"

# Find redirects
docker-compose logs app --tail=500 | grep -E "Redirect|302 Found"

# Find CanCan errors
docker-compose logs app --tail=500 | grep -i "cancan\|access denied"

# See full request flow
docker-compose logs app --tail=1000 | grep -B 5 -A 10 "GET \"/wydarzenia\""
```

### Production/Staging Logs (Kamal)

```bash
# Staging
kamal app logs -d staging --reuse -f

# Production
kamal app logs -d production --reuse -f | grep ERROR
```

---

## Common Debugging Scenarios

### Scenario 1: Unexpected Redirect

**Symptoms:** Page redirects to homepage with flash message

**Debug steps:**
```bash
# 1. Check HTTP redirect
curl -v -b cookies.txt http://localhost:3002/wydarzenia 2>&1 | grep Location

# 2. Check Rails logs for the redirect
docker-compose logs app --tail=200 | grep -B 5 -A 5 "Redirected to"

# 3. Check for CanCan or authorization issues
docker-compose exec -T app bundle exec rails runner "
  user = Db::User.find_by(email: 'dariusz.finster@gmail.com')
  ability = Ability.new(user)
  puts ability.can?(:index, Training::Supplementary::CourseRecord)
"

# 4. Check controller filters
grep -r "before_action" app/components/training/supplementary/
```

### Scenario 2: Form Submission Fails

**Debug steps:**
```ruby
# tmp/playwright/debug_form.rb
require File.join(Rails.root, 'lib', 'playwright', 'login_helper')

Playwright::LoginHelper.new(environment: :development, headless: false).start do |helper|
  helper.login
  helper.goto("#{helper.base_url}/some/form")
  
  # Fill form
  helper.fill('#field_name', 'test value')
  helper.click('button[type="submit"]')
  
  # Check errors
  puts "Console logs: #{helper.console_logs.inspect}"
  puts "Page errors: #{helper.errors.inspect}"
  
  if helper.has_element?('.error')
    puts "Errors: #{helper.text_content('.error')}"
  end
  
  helper.screenshot("form_result")
  sleep 10
end
```

### Scenario 3: Permission Denied

**Debug steps:**
```ruby
# Rails console
user = Db::User.find_by(email: 'user@example.com')

# 1. Check roles
puts "Roles: #{user.roles}"

# 2. Check profile status
puts "Profile position: #{user.profile&.position}"

# 3. Check membership
activement = Membership::Activement.new(user: user)
puts "Active: #{activement.active?}"
puts "Released: #{activement.profile_has_been_released?(user)}"

# 4. Test specific ability
ability = Ability.new(user)
puts "Can access?: #{ability.can?(:action, Model)}"

# 5. See what they CAN do
puts "\nPermissions:"
ability.permissions.each { |p| puts "  - #{p}" }
```

### Scenario 4: Database State Issue

```ruby
# Check record state
course = Training::Supplementary::CourseRecord.find(123)
puts course.attributes
puts "State: #{course.state}"
puts "Category: #{course.category}"

# Check associations
puts "Sign ups: #{course.sign_ups.count}"
course.sign_ups.each do |signup|
  puts "  - #{signup.name} (#{signup.email})"
end

# Check scopes/queries
active = Training::Supplementary::Repository.new.fetch_active_courses
puts "Active courses: #{active.count}"
```

---

## Quick Reference Commands

### Authentication
```bash
# curl login (development) - CORRECT WAY with Devise session cookies
# Get page and extract token properly
curl -s -c cookies.txt http://localhost:3002/users/sign_in > /tmp/login.html
TOKEN=$(grep -o 'name="authenticity_token" value="[^"]*"' /tmp/login.html | cut -d'"' -f4)

# Login with cookies saved and sent
curl -c cookies.txt -b cookies.txt -X POST http://localhost:3002/users/sign_in \
  -d "authenticity_token=$TOKEN" \
  -d "user[email]=EMAIL" \
  -d "user[password]=PASSWORD" \
  -H "Accept: text/html"

# Verify Set-Cookie in response
curl -v -c cookies.txt -b cookies.txt -X POST http://localhost:3002/users/sign_in \
  -d "authenticity_token=$TOKEN" \
  -d "user[email]=EMAIL" \
  -d "user[password]=PASSWORD" \
  -H "Accept: text/html" 2>&1 | grep Set-Cookie

# Check if logged in (look for logout link)
curl -b cookies.txt http://localhost:3002/ | grep "Wyloguj\|sign_out"

# Verify current_user is set (add debug logs first, then check)
curl -s -H "Accept: text/html" -b cookies.txt http://localhost:3002/wydarzenia > /dev/null
docker-compose logs app --tail=20 | grep "Current user"
```

### Permissions Check
```bash
docker-compose exec -T app bundle exec rails runner "
  user = Db::User.find_by(email: 'EMAIL')
  ability = Ability.new(user)
  puts 'Roles: ' + user.roles.inspect
  puts 'Can index events: ' + ability.can?(:index, Training::Supplementary::CourseRecord).to_s
"
```

### Playwright Quick Test
```bash
docker-compose exec -T app bundle exec rails runner "$(cat tmp/playwright/SCRIPT.rb)"
```

### Log Grep Patterns
```bash
# Redirects
docker-compose logs app | grep "Redirected to"

# Errors
docker-compose logs app | grep -i "error\|exception"

# Specific controller
docker-compose logs app | grep "CoursesController"

# With context
docker-compose logs app | grep -B 5 -A 5 "pattern"
```

---

## Debugging Checklist

When investigating an issue:

- [ ] Can you reproduce it locally?
- [ ] What's the expected behavior vs actual behavior?
- [ ] Try quick curl test (authenticated)
- [ ] Check HTTP response codes (200, 302, 403, 500?)
- [ ] Check Rails logs for errors/redirects
- [ ] Is `current_user` nil? (auth issue)
- [ ] Check user roles: `user.roles`
- [ ] Check abilities: `ability.can?(:action, Model)`
- [ ] Try with different user roles
- [ ] Verify routes exist: `rails routes | grep pattern`
- [ ] Check for `before_action` filters
- [ ] Check for `rescue_from` blocks
- [ ] Add temporary debug logs if still unclear
- [ ] Check for JavaScript errors (browser if needed)
- [ ] Check database state (console)
- [ ] Remove debug logs after fix!

**For curl issues specifically:**
- [ ] Did login return `Set-Cookie`?
- [ ] Using `-c` to save AND `-b` to send cookies?
- [ ] Same cookie file for all requests?
- [ ] Token extraction pattern correct?
- [ ] Added `Accept: text/html` header?