# Known Issues & Solutions

> Tracking issues encountered during Rails 8 migration and framework upgrades.
> **Last Updated:** 2024

---

## 🔧 Active Issues

### ❌ `NoMethodError: undefined method 'with'` in Dry::Validation::Contract

**Status:** ⚠️ Partially Fixed (1 of 2+ occurrences)

**Affected Files:**
- ✅ `app/components/training/supplementary/create_course.rb` - **FIXED**
- ❌ `app/components/settlement/update_contract.rb` - **NEEDS FIX** (lines 11 & 13)
- ❌ `app/components/events/competitions/sign_ups/create.rb` - **NEEDS FIX** (line 11)
- ❌ `app/components/events/competitions/sign_ups/update.rb` - **NEEDS FIX** (line 12)
- ⚠️ Other services using `Dry::Validation::Contract` - **NEEDS AUDIT**

**Error:**
```
NoMethodError: undefined method `with' for Training::Supplementary::CreateCourseForm:Class
```

**Root Cause:**
Code was attempting to call `.with(option: value)` on `Dry::Validation::Contract` instances or classes, but this method doesn't exist in dry-validation 1.10.0. The correct method is `.new(option: value)`.

**Incorrect Pattern:**
```ruby
# ❌ WRONG - Calling .with() on instance
form = SomeForm.new
form.with(record: record).call(inputs)

# ❌ WRONG - Calling .with() on class (even after constantize)
SomeForm.with(record: record).call(inputs)
```

**Correct Pattern:**
```ruby
# ✅ CORRECT - Pass options to .new()
form_class = SomeForm
form_class.new(record: record).call(inputs)

# Form must define options using dry-initializer
class SomeForm < Dry::Validation::Contract
  option :record, default: -> { nil }
  # ...
end

# Service must require result/failure/success files
require 'result'
require 'failure'
require 'success'
```

**Additional Fix Required:**
Also need to use `.errors.to_h` instead of `.messages` for dry-validation results, and wrap in proper Failure pattern:

```ruby
# ❌ WRONG
return Failure(form_outputs.messages) unless form_outputs.success?

# ✅ CORRECT
return Failure(:invalid, errors: form_outputs.errors.to_h) unless form_outputs.success?

# Service must include requires at the top
require 'result'
require 'failure'
require 'success'
```

**Action Items:**
- [x] Fix `Training::Supplementary::CreateCourse` (`.with()` → `.new()`, add requires)
- [x] Write spec for `Training::Supplementary::CreateCourse`
- [ ] Fix `Settlement::UpdateContract` (lines 11 & 13)
- [ ] Fix `Events::Competitions::SignUps::Create` (line 11)
- [ ] Fix `Events::Competitions::SignUps::Update` (line 12)
- [ ] Write specs for all fixed services
- [ ] Audit all services using `Dry::Validation::Contract` for `.with()` calls
- [ ] Audit all services for `.messages` vs `.errors.to_h` usage
- [ ] Audit all services for `.messages(locale:)` vs `.errors.to_h` usage

**Search Commands:**
```bash
# Find other occurrences
grep -r "\.with(" app/components/ | grep -i "form"
grep -r "form_outputs\.messages" app/components/
```

---

### ❌ `NoMethodError: undefined method 'success?' for false:FalseClass` with `either()` helper

**Status:** ✅ Resolved

**Affected Files:**
- ✅ `app/components/training/supplementary/courses_controller.rb` - **FIXED**

**Error:**
```
NoMethodError: undefined method `success?' for false:FalseClass
Did you mean? Success
```

**Root Cause:**
The `either()` helper from `EitherMatcher` expects `Dry::Monads::Either` results, but our service objects return custom `Result` objects (Success/Failure from `lib/result.rb`). When `EitherMatcher` tries to call `.success?` on our `Result`, it hits the `method_missing` which returns `false`, causing the error.

**Incorrect Pattern:**
```ruby
# ❌ WRONG - Using either() with custom Result objects
def create
  either(create_record) do |result|
    result.success do
      # ...
    end
    
    result.failure do |errors|
      # ...
    end
  end
end
```

**Correct Pattern:**
```ruby
# ✅ CORRECT - Direct Result handling
def create
  result = create_record
  
  result.success do
    redirect_to some_path, flash: { notice: 'Success!' }
  end

  result.invalid do |errors:|
    @errors = errors.values
    render :new
  end
end
```

**Additional Requirements:**
- Services must return custom `Result` objects (Success/Failure)
- Services must require `result`, `failure`, and `success` files
- Form validation failures should use `:invalid` as the failure name
- Pass errors as keyword argument: `Failure(:invalid, errors: form_outputs.errors.to_h)`

**Action Items:**
- [x] Fix `Training::Supplementary::CoursesController#create`
- [x] Update form to accept all permitted parameters
- [x] Write comprehensive specs (10 tests)
- [ ] Audit other controllers using `either()` with custom Result objects

---

## 📋 Resolved Issues

_(Issues moved here once fully resolved across all occurrences)_

---

## 🔍 How to Use This Document

### For Developers
1. **Before fixing a bug:** Check if it's already documented here
2. **After fixing a bug:** Update this document with the solution
3. **When encountering new issues:** Add them to "Active Issues" section

### For AI Assistants
1. **Search this file** before attempting complex fixes
2. **Reference known patterns** when suggesting solutions
3. **Update this file** after resolving issues
4. **Suggest audits** when patterns indicate widespread issues

### Template for New Issues

```markdown
### ❌ Brief Description of Error

**Status:** 🔴 Active / ⚠️ Partially Fixed / ✅ Resolved

**Affected Files:**
- ❌ `path/to/file.rb` - **NEEDS FIX**
- ✅ `path/to/other.rb` - **FIXED**

**Error:**
```
Full error message here
```

**Root Cause:**
Explanation of why this happens

**Incorrect Pattern:**
```ruby
# ❌ Code that causes the error
```

**Correct Pattern:**
```ruby
# ✅ Fixed code
```

**Action Items:**
- [ ] Task 1
- [x] Task 2

**Related Issues:**
- Link to GitHub issues
- Link to other docs
```

---

## 🚨 Migration Checklist

Use this checklist when upgrading major versions:

- [ ] Audit all `Dry::Validation::Contract` subclasses
  - [ ] Check for `.with()` usage (should be `.new()`)
  - [ ] Check for `.messages` usage (should be `.errors.to_h`)
- [ ] Audit all form validation error handling
- [ ] Audit controllers using `either()` helper
  - [ ]Run full test suite after each gem upgrade
- [ ] Check deprecation warnings in logs
- [ ] Review CHANGELOG for breaking changes in:
  - [ ] dry-validation
  - [ ] dry-schema
  - [ ] dry-initializer
  - [ ] Rails
  - [ ] Other major dependencies

---

## 📚 Related Documentation

- [Rails 8 Migration Guide](RAILS_8_MIGRATION_GUIDE.md)
- [Database Migration Verification](database-migration-verification.md)
- [CLAUDE.md](../CLAUDE.md) - AI assistant guidelines
- [Dry-validation Docs](https://dry-rb.org/gems/dry-validation/)

---

## 🤝 Contributing

When adding issues to this document:
1. Be specific about versions (gem versions, Rails version)
2. Include full error messages
3. Provide both incorrect and correct code examples
4. Link to relevant specs that test the fix
5. Move to "Resolved" section only when ALL occurrences are fixed