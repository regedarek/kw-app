# Refactoring Plan: Migrate from EitherMatcher/Custom Result to Dry::Monads

**Status:** 🟡 In Progress  
**Created:** 2024  
**Owner:** Engineering Team  
**Priority:** High

---

## 📋 Executive Summary

We're migrating from our custom `Result` pattern (in `lib/result.rb`) and the `EitherMatcher` wrapper to using `dry-monads` directly. This will:

1. **Standardize** on industry-standard patterns
2. **Improve** type safety and error handling
3. **Simplify** controller/service interactions
4. **Enable** better use of Railway-Oriented Programming

---

## 🎯 Goals

- [ ] Write request specs for all controllers (TEST FIRST!)
- [ ] Migrate services/operations module-by-module to use `Dry::Monads[:result, :do]`
- [ ] Update controllers module-by-module to use `Dry::Matcher::ResultMatcher` directly
- [ ] Run specs after each module migration
- [ ] Remove custom `Result` class from `lib/result.rb` (final step)
- [ ] Remove `EitherMatcher` module from `app/components/either_matcher.rb` (final step)

---

## 📊 Current State Analysis

### Files Using EitherMatcher

**Total Controllers Including EitherMatcher:** 31+

#### Pattern A: Using `either()` Helper (19+ usages)
Controllers that call `either(operation_result)`:

1. `app/components/events/admin/competitions_controller.rb` (2 usages)
2. `app/components/events/competitions/sign_ups_controller.rb` (2 usages)
3. `app/components/management/projects_controller.rb` (2 usages)
4. `app/components/management/voting/cases_controller.rb` (2 usages)
5. `app/components/management/voting/commissions_controller.rb` (1 usage)
6. `app/components/management/voting/votes_controller.rb` (1 usage)
7. `app/components/reservations/items_controller.rb` (1 usage)
8. `app/components/settlement/admin/contractors_controller.rb` (1 usage)
9. `app/components/settlement/admin/contracts_controller.rb` (2 usages)
10. `app/components/training/activities/ski_routes_controller.rb` (2 usages)
11. `app/components/training/supplementary/packages_controller.rb` (1 usage)
12. `app/components/training/supplementary/sign_ups_controller.rb` (4 usages)

#### Pattern B: Direct Result Method Calls (no `either()`)
Controllers that use Result directly:

1. `app/components/business/payments_controller.rb`
   - Custom methods: `success`, `wrong_payment_url`, `dotpay_request_error`
2. `app/components/charity/donations_controller.rb`
   - Custom methods: `success`, `invalid`, `else_fail!`
3. Many controllers include `EitherMatcher` but don't actively use it

#### Pattern C: Already Using Dry::Matcher::ResultMatcher
1. `app/components/profile_creation/v2/profiles_controller.rb` ✅
   - Uses `Dry::Matcher::ResultMatcher` directly
   - Good example of target pattern
   
**Note:** The ProjectCreation::Operation::Create example provided in the initial request is our target pattern for this codebase.

### Services/Operations

#### Already Migrated ✅
1. `app/components/profile_creation/operation/create.rb`
   - Uses `include Dry::Monads[:maybe, :try, :result, :do]`
   - Returns `Success(profile)` / `Failure([:code, errors])`
   - **This is our reference implementation** ✅

**Target Pattern:** The ProjectCreation::Operation::Create example from the initial request shows the exact pattern we want to adopt throughout the codebase.

#### Still Using Custom Result ❌
- Various services in `app/components/` (need to audit)
- Services in `app/services/` (e.g., `Payments::CreatePayment`)

---

## 🔄 Migration Strategy

### ⚠️ CRITICAL: Test-First Approach

**Before migrating ANY module, we MUST:**

1. **Write Request Specs** - Full coverage of controller actions
2. **Verify Specs Pass** - Establish baseline with current code
3. **Migrate Code** - Apply refactoring
4. **Run Specs Again** - Ensure nothing broke

**No specs = No migration!**

---

### Phase 1: Audit & Test Coverage (Week 1)

**Goal:** Create complete inventory and establish test coverage baseline

#### Tasks:
- [x] Document all controllers using `EitherMatcher`
- [x] Document all controllers using `either()` method
- [x] Document all controllers using custom Result directly
- [ ] **Create audit spreadsheet** with:
  - Service/Operation name
  - Controller that calls it
  - Current result types returned (e.g., `:success`, `:invalid`, `:unauthorized`)
  - Migration complexity (Low/Medium/High)
  - **Test coverage status** (None/Partial/Full)
- [ ] **Write request specs for ALL controllers** (if missing)
- [ ] Group services/controllers by module/domain
- [ ] Identify services shared by multiple controllers
- [ ] Run full test suite to establish baseline
- [ ] Create feature branch: `refactor/dry-monads-migration`

#### Deliverables:
- Complete inventory spreadsheet with test coverage
- **Request specs for all affected controllers** ✅
- List of modules sorted by priority (least dependencies first)
- Test baseline report

---

### Phase 2: Module-by-Module Migration (Weeks 2-7)

**Goal:** Convert modules one at a time, with full test coverage at each step

**Important:** Each module follows this cycle:
1. ✅ Write/verify request specs
2. 🔧 Migrate service(s)
3. 🔧 Migrate controller(s)
4. ✅ Run specs - must pass!
5. 📝 Commit module
6. ➡️ Move to next module

**DO NOT migrate multiple modules simultaneously!**

#### Migration Pattern for Services

**BEFORE (Custom Result):**
```ruby
class Business::CreatePayment
  def create
    return Failure.new(:wrong_payment_url, message: "Invalid URL") unless valid_url?
    return Failure.new(:dotpay_request_error, message: "API failed") unless api_success?
    
    Success.new(:success, payment_url: url)
  end
end
```

**AFTER (Dry::Monads):**
```ruby
class Business::CreatePayment
  include Dry::Monads[:result, :do, :try]
  
  def create
    yield validate_url
    url = yield call_dotpay_api
    
    Success(url)
  end
  
  private
  
  def validate_url
    if valid_url?
      Success()
    else
      Failure([:wrong_payment_url, "Invalid URL"])
    end
  end
  
  def call_dotpay_api
    Try do
      # API call
    end.to_result.or { |error| Failure([:dotpay_request_error, "API failed: #{error.message}"]) }
  end
end
```

#### Key Changes:
1. Add `include Dry::Monads[:result, :do, :try]`
2. Change `Success.new(:name, args)` → `Success(value)` or `Success()`
3. Change `Failure.new(:name, args)` → `Failure([:code, message])`
4. Use `yield` with Do notation for step-by-step validation
5. Use `Try` monad for exception handling
6. Return tuple `[:code, data]` in Failure for pattern matching

#### Module Migration Order:

**Week 2: Training::Supplementary Module (Start Here - Low Complexity)**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/training/supplementary/packages_controller_spec.rb`
  - [ ] `spec/requests/training/supplementary/sign_ups_controller_spec.rb`
  - [ ] Test all actions and result paths
  - [ ] Run specs - ensure they pass
- [ ] **Step 2: Migrate Services**
  - [ ] `Training::Supplementary::CreateCourse`
  - [ ] Change to `include Dry::Monads[:result, :do]`
  - [ ] Update Success/Failure calls
  - [ ] Run specs - should still pass
- [ ] **Step 3: Migrate Controllers**
  - [ ] `Training::Supplementary::PackagesController`
  - [ ] `Training::Supplementary::SignUpsController`
  - [ ] Remove `include EitherMatcher`
  - [ ] Use `Dry::Matcher::ResultMatcher`
  - [ ] Run specs - must pass!
- [ ] **Step 4: Commit**
  - [ ] `git commit -m "refactor(training/supplementary): migrate to dry-monads"`

**Week 2: Charity Module (Low Complexity)**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/charity/donations_controller_spec.rb`
  - [ ] Test all actions: `new`, `create`
  - [ ] Test success and failure paths
  - [ ] Run specs - ensure they pass
- [ ] **Step 2: Migrate Service**
  - [ ] `Charity::CreateDonation`
  - [ ] Change to `include Dry::Monads[:result, :do]`
  - [ ] Update Success/Failure calls
  - [ ] Run specs - should still pass
- [ ] **Step 3: Migrate Controller**
  - [ ] `Charity::DonationsController`
  - [ ] Remove `include EitherMatcher`
  - [ ] Use `Dry::Matcher::ResultMatcher`
  - [ ] Run specs - must pass!
- [ ] **Step 4: Commit**
  - [ ] `git commit -m "refactor(charity): migrate to dry-monads"`

**Week 3: Business Module (Medium Complexity)**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/business/payments_controller_spec.rb`
  - [ ] Test `charge` action with all result types
  - [ ] Run specs - ensure they pass
- [ ] **Step 2: Migrate Service**
  - [ ] `Payments::CreatePayment`
  - [ ] Handle multiple failure types: `:wrong_payment_url`, `:dotpay_request_error`
- [ ] **Step 3: Migrate Controller**
  - [ ] `Business::PaymentsController`
  - [ ] Convert direct Result calls to ResultMatcher
- [ ] **Step 4: Run Specs & Commit**

**Week 3: Reservations Module**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/reservations/items_controller_spec.rb`
- [ ] **Step 2-4:** Migrate service → controller → test → commit

**Week 4: Management::Voting Module**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/management/voting/votes_controller_spec.rb`
  - [ ] `spec/requests/management/voting/commissions_controller_spec.rb`
  - [ ] `spec/requests/management/voting/cases_controller_spec.rb`
- [ ] **Step 2-4:** Migrate services → controllers → test → commit

**Week 4: Management::Projects Module**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/management/projects_controller_spec.rb`
- [ ] **Step 2-4:** Migrate service → controller → test → commit

**Week 5: Events Module**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/events/admin/competitions_controller_spec.rb`
  - [ ] `spec/requests/events/competitions/sign_ups_controller_spec.rb`
- [ ] **Step 2-4:** Migrate services → controllers → test → commit

**Week 6: Settlement Module**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/settlement/admin/contractors_controller_spec.rb`
  - [ ] `spec/requests/settlement/admin/contracts_controller_spec.rb`
- [ ] **Step 2-4:** Migrate services → controllers → test → commit

**Week 7: Training::Activities Module**
- [ ] **Step 1: Write Request Specs**
  - [ ] `spec/requests/training/activities/ski_routes_controller_spec.rb`
- [ ] **Step 2-4:** Migrate service → controller → test → commit

#### For Each Module Migration:
1. [ ] ✅ **WRITE REQUEST SPECS FIRST** (if not exist)
2. [ ] ✅ Run specs - must pass with current code
3. [ ] 🔧 Migrate service to use Dry::Monads
4. [ ] 🔧 Migrate controller to use ResultMatcher
5. [ ] ✅ Run specs - must pass with new code
6. [ ] 📝 Commit module: `refactor([module]): migrate to dry-monads`
7. [ ] ➡️ Move to next module

---

### Phase 3: Cleanup Unused Includes (Week 8)

**Goal:** Remove `include EitherMatcher` from controllers that don't use it

#### Pattern A Migration: `either()` Helper → `ResultMatcher`

**BEFORE:**
```ruby
class Management::ProjectsController < ApplicationController
  include EitherMatcher
  
  def create
    either(create_record) do |result|
      result.success do
        redirect_to projects_path, notice: 'Created'
      end
      
      result.failure do |errors|
        @errors = errors
        render :new
      end
    end
  end
end
```

**AFTER:**
```ruby
class Management::ProjectsController < ApplicationController
  
  def create
    Dry::Matcher::ResultMatcher.(create_record) do |result|
      result.success do |project|
        redirect_to projects_path, notice: 'Created'
      end
      
      result.failure :invalid do |code, errors|
        @errors = errors
        render :new
      end
      
      result.failure :unauthorized do |code, message|
        redirect_to root_path, alert: message
      end
      
      result.failure do |code, error|
        redirect_to root_path, alert: "Error: #{error}"
      end
    end
  end
end
```

#### Pattern B Migration: Direct Result → `ResultMatcher`

**BEFORE:**
```ruby
class Business::PaymentsController < ApplicationController
  include EitherMatcher
  
  def charge
    result = Payments::CreatePayment.new(payment: payment).create
    
    result.success do |payment_url:|
      redirect_to payment_url, alert: 'Created', allow_other_host: true
    end
    
    result.wrong_payment_url { |message:| redirect_to root_path, alert: message }
    
    result.dotpay_request_error do |message:|
      # ... dev environment special handling
      redirect_to root_path, alert: message
    end
  end
end
```

**AFTER:**
```ruby
class Business::PaymentsController < ApplicationController
  
  def charge
    Dry::Matcher::ResultMatcher.(Payments::CreatePayment.new(payment: payment).create) do |result|
      result.success do |payment_url|
        redirect_to payment_url, alert: 'Created', allow_other_host: true
      end
      
      result.failure :wrong_payment_url do |code, message|
        redirect_to root_path, alert: message
      end
      
      result.failure :dotpay_request_error do |code, message|
        if Rails.env.development?
          # ... dev environment special handling
        else
          redirect_to root_path, alert: message
        end
      end
      
      result.failure do |code, error|
        redirect_to root_path, alert: "Payment error: #{error}"
      end
    end
  end
end
```

#### Key Changes:
1. Remove `include EitherMatcher`
2. Replace `either()` with `Dry::Matcher::ResultMatcher.()`
3. Add specific failure type matching: `result.failure :type_name do |code, data|`
4. Add catch-all failure handler at the end
5. Update block parameters (no keyword args, use positional)

#### Controllers Only Using Include (No Migration Needed):

These controllers include `EitherMatcher` but don't actively use `either()` or custom Result. Just remove the include statement:

- [ ] `Activities::RoutesController` - Remove include only
- [ ] `Business::ListsController` - Remove include only
- [ ] `Business::SignUpsController` - Remove include only
- [ ] `Club::MeetingsIdeasController` - Remove include only
- [ ] `Library::Admin::TagsController` - Remove include only
- [ ] `Library::AuthorsController` - Remove include only
- [ ] `Library::ItemsController` - Remove include only
- [ ] `Management::ResolutionsController` - Remove include only
- [ ] `Management::SettingsController` - Remove include only
- [ ] `Management::Voting::CasePresencesController` - Remove include only
- [ ] `Settlement::Admin::ProjectsController` - Remove include only
- [ ] `Training::Activities::ContractsController` - Remove include only
- [ ] `Training::Activities::UserContractsController` - Remove include only
- [ ] `Training::Bluebook::ExercisesController` - Remove include only
- [ ] `UserManagement::ListsController` - Remove include only

**For each:** Remove `include EitherMatcher`, run specs, commit.

---

### Phase 4: Remove Legacy Code (Week 8)

**Goal:** Clean up custom Result and EitherMatcher

#### Tasks:
- [ ] Verify all controllers migrated (grep for `include EitherMatcher`)
- [ ] Verify all services migrated (grep for `Success.new` / `Failure.new`)
- [ ] Run full test suite
- [ ] Delete `lib/result.rb`
- [ ] Delete `app/components/either_matcher.rb`
- [ ] Update documentation:
  - [ ] `.agents/refactor.md`
  - [ ] `.agents/service.md`
  - [ ] `CLAUDE.md`
- [ ] Run test suite again
- [ ] Create PR for review

---

## 🧪 Testing Strategy (TEST-FIRST!)

### ⚠️ CRITICAL: Write Tests BEFORE Refactoring

**Golden Rule:** No specs = No refactoring!

### Phase 1: Write Request Specs

Before touching ANY code, write comprehensive request specs for each controller action:

```ruby
# spec/requests/charity/donations_controller_spec.rb
require 'rails_helper'

RSpec.describe "Charity::Donations", type: :request do
  describe "GET /charity/donations/new" do
    it "returns http success" do
      get new_charity_donation_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /charity/donations" do
    context "with valid params" do
      let(:valid_params) do
        { donation: { cost: 100, display_name: "John", terms_of_service: true } }
      end

      it "creates donation and redirects to payment" do
        post charity_donations_path, params: valid_params
        expect(response).to redirect_to(charge_payment_path(assigns(:payment)))
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        { donation: { cost: nil } }
      end

      it "redirects with error message" do
        post charity_donations_path, params: invalid_params
        expect(response).to redirect_to(michal_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
```

### Phase 2: Verify Baseline

```bash
# Run specs BEFORE refactoring - must pass!
docker-compose exec -T app bundle exec rspec spec/requests/charity/donations_controller_spec.rb
```

### Phase 3: After Each Module Migration

```bash
# Run module specs after refactoring - must STILL pass!
docker-compose exec -T app bundle exec rspec spec/requests/charity/
docker-compose exec -T app bundle exec rspec spec/requests/business/
# etc...
```

### Request Spec Template for Each Controller:

```ruby
require 'rails_helper'

RSpec.describe "[Module]::[Controller]", type: :request do
  # Setup
  let(:user) { create(:user) }
  
  before do
    sign_in user  # if authentication required
  end

  describe "GET /path/to/new" do
    it "renders new form" do
      get new_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe "POST /path/to/create" do
    context "when operation succeeds" do
      let(:valid_params) { { key: "value" } }

      it "creates record and redirects with notice" do
        expect {
          post create_path, params: valid_params
        }.to change(Record, :count).by(1)
        
        expect(response).to redirect_to(expected_path)
        expect(flash[:notice]).to eq("Created successfully")
      end
    end

    context "when validation fails" do
      let(:invalid_params) { { key: "" } }

      it "renders form with errors" do
        post create_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(assigns(:errors)).to be_present
      end
    end

    context "when not authorized" do
      let(:guest) { create(:user, role: :guest) }
      
      before { sign_in guest }

      it "redirects with alert" do
        post create_path, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end
end
```

### Critical Paths to Test:
- [ ] **All success paths** - Happy flow works
- [ ] **All validation failures** - Errors displayed correctly
- [ ] **Authorization failures** - Proper access control
- [ ] **Not found errors** - 404 handling
- [ ] **Edge cases** - Nil values, empty arrays, etc.

### Test Coverage Requirements:

**Minimum Coverage per Controller:**
- ✅ All actions have specs
- ✅ Success path tested
- ✅ At least 2 failure paths tested
- ✅ Authorization tested (if applicable)

### Integration Tests (After All Modules):
- [ ] Test critical user flows end-to-end
- [ ] Test payment flows
- [ ] Test voting/management flows
- [ ] Test event sign-ups

---

## 📚 Reference Implementation

### Target Pattern: ProjectCreation::Operation::Create

**This is the ideal pattern we're migrating towards:**

```ruby
require "dry/monads"

class ProjectCreation::Operation::Create
  include Dry::Monads[:maybe, :try, :result, :do]

  def call(params: {}, council:, current_user:, import: false)
    project_params =  yield validate(params: params, council: council)
                      yield authorize!(current_user: current_user, council: council)
                      yield check_project_name_uniqueness!(params: project_params, council: council)
    stage_template =  yield fetch_stage_template(params: project_params, council: council)
    project_params =  yield apply_default_params(params: project_params, stage_template: stage_template)

    completed_project = ActiveRecord::Base.transaction do
      project = yield create_project(params: project_params, council: council, current_user: current_user)
                yield ProjectCreation::Operation::AssignRatingTemplates.new.call(params: { project_id: project.id }, council: council)
                yield ProjectCreation::Operation::AssignDefaultStages.new.call(params: { project_id: project.id }, council: council)
                # ... more yields for other operations
                
                project
    end

    Success(completed_project)
  end

  def validate(params:, council:)
    Dry::Schema.Params do
      required(:name).filled(:string)
      required(:stage_template_id).filled(:string, :uuid_v4?, included_in?: StageTemplate.where(council: council).pluck(:id))
      required(:visibility).filled(:string, included_in?: Project.visibilities.keys)
      optional(:start_date).maybe(:date_time)
      optional(:description).maybe(:string)
    end.call(params)
      .to_monad
      .fmap { |params| params.to_h }
      .or   { |schema| Failure([ :invalid, schema.errors.to_h ]) }
  end

  def authorize!(current_user:, council:)
    if ::ProjectPolicy.new(current_user, Project.new).create?
      Success(:authorized)
    else
      Failure([ :unauthorized, "You are not authorized to create a project" ])
    end
  end

  def check_project_name_uniqueness!(params:, council:)
    if council.projects.where(discarded_at: nil, name: params[:name]).exists?
      Failure([ :invalid, "Project with the same name already exists" ])
    else
      Success(:name_unique)
    end
  end

  def fetch_stage_template(params:, council:)
    if params[:stage_template_id].present?
      Maybe(StageTemplate.find_by(id: params.dig(:stage_template_id), council: council))
        .to_result
        .or { Failure([ :not_found, "Stage template doesnt exists" ]) }
    else
      Maybe(council.stage_templates.find_by(resource_type: :project, default_template: true))
        .to_result
        .or { Failure([ :not_found, "Default stage template not found" ]) }
    end
  end

  def create_project(params:, council:, current_user:)
    Try do
      params = params.merge!(council_id: council.id, created_by_id: current_user.id)
      Project.create!(params)
    end.to_result
      .or { |error| Failure([ :invalid, error.message ]) }
  end
end
```

### Controller Pattern: ResultMatcher

```ruby
module ProjectCreation
  class Api::V3::ProjectsController < ::Api::V1::BaseController
    def create
      Dry::Matcher::ResultMatcher.(project_creation_operation.call(params: params.to_unsafe_h, council: @council, current_user: current_api_v1_user)) do |result|
        result.success do |project|
          render json: project.as_json.merge!(redirect_approval_task_id: project.redirect_approval_task_id), status: 201
        end

        result.failure :not_found do |code, errors|
          render json: { code: code, message: errors }, status: :not_found
        end

        result.failure :invalid do |code, errors|
          Appsignal.report_error(StandardError.new("project not created")) do |transaction|
            transaction.set_params({ errors: errors, council: @council.name })
          end
          render json: { code: code, message: errors }, status: :unprocessable_entity
        end

        result.failure :unauthorized do |code, errors|
          render json: { code: code, message: errors }, status: :forbidden
        end

        result.failure do |errors|
          render json: errors, status: :unprocessable_entity
        end
      end
    end
  end
end
```

### Also Already Migrated ✅

`app/components/profile_creation/operation/create.rb` - Similar pattern to ProjectCreation above.

---

## 🔍 Common Patterns & Solutions

### Pattern: Multiple Failure Types

**Services should return:**
```ruby
Failure([:not_found, "User not found"])
Failure([:invalid, { name: ["can't be blank"] }])
Failure([:unauthorized, "Insufficient permissions"])
Failure([:error, "Database error"])
```

**Controllers match on type:**
```ruby
result.failure :not_found do |code, message|
  # handle not found
end

result.failure :invalid do |code, errors_hash|
  # handle validation errors
end

result.failure :unauthorized do |code, message|
  # handle authorization
end

result.failure do |code, error|
  # catch-all for unhandled types
end
```

### Pattern: Transaction Handling

```ruby
def call(params:)
  ActiveRecord::Base.transaction do
    project = yield create_project(params)
    yield assign_members(project, params)
    yield notify_members(project)
    
    Success(project)
  end
rescue ActiveRecord::RecordInvalid => e
  Failure([:invalid, e.record.errors.full_messages])
end
```

### Pattern: Try Monad for Exceptions

```ruby
def call_external_api
  Try do
    HTTParty.get(url)
  end.to_result.or { |error| Failure([:api_error, error.message]) }
end
```

### Pattern: Maybe Monad for Nil Checks

```ruby
def fetch_user(id:)
  Maybe(User.find_by(id: id))
    .to_result
    .or { Failure([:not_found, "User not found"]) }
end
```

---

## 🚨 Known Issues & Solutions

### Issue: Keyword Arguments vs Positional

**Old custom Result:**
```ruby
result.success { |payment_url:, id:| ... }
```

**New Dry::Monads:**
```ruby
# Return hash
Success({ payment_url: url, id: id })

# Controller receives positional
result.success do |data|
  payment_url = data[:payment_url]
  id = data[:id]
end

# OR return single value and pass multiple in tuple
Success([url, id])

result.success do |url, id|
  # ...
end
```

### Issue: `else_fail!` Pattern

**Old:**
```ruby
result.success { ... }
result.invalid { ... }
result.else_fail!  # raises if no handler matched
```

**New:**
```ruby
result.success { ... }
result.failure :invalid { ... }
result.failure do |code, error|
  # catch-all - always add this or raise explicitly
  raise "Unhandled failure: #{code} - #{error}"
end
```

---

## 📝 Documentation Updates

After migration, update these files:

- [ ] `.agents/refactor.md` - Remove `EitherMatcher` references
- [ ] `.agents/service.md` - Update service patterns
- [ ] `CLAUDE.md` - Update AI guidelines
- [ ] `docs/KNOWN_ISSUES.md` - Remove Result migration issues
- [ ] Create this file: `docs/DRY_MONADS_GUIDE.md` - Developer reference

---

## ✅ Definition of Done

- [ ] Zero references to `EitherMatcher` in codebase
- [ ] Zero references to `lib/result.rb` in codebase
- [ ] All services use `include Dry::Monads[:result, :do]`
- [ ] All controllers use `Dry::Matcher::ResultMatcher` directly
- [ ] Full test suite passes (RSpec + system tests)
- [ ] Manual testing of critical paths
- [ ] Code review approved
- [ ] Documentation updated
- [ ] Merged to main branch

---

## 🤝 Team Responsibilities

### Developer Responsibilities:
- Follow this plan sequentially
- Run tests after each change
- Commit frequently with descriptive messages
- Ask for help if stuck >2 hours

### Reviewer Responsibilities:
- Check for consistent pattern usage
- Verify test coverage
- Ensure error handling is comprehensive
- Validate documentation updates

---

## 📞 Need Help?

- **Pattern questions:** Check reference implementations above
- **Service migration:** See Phase 2 examples
- **Controller migration:** See Phase 3 examples
- **Blocked/Confused:** Review `docs/KNOWN_ISSUES.md` first

---

## 🎓 Learning Resources

- [dry-monads Documentation](https://dry-rb.org/gems/dry-monads/)
- [Railway-Oriented Programming](https://fsharpforfunandprofit.com/rop/)
- [Do notation guide](https://dry-rb.org/gems/dry-monads/1.3/do-notation/)
- Internal: `.agents/service.md` - Operation patterns

---

**Last Updated:** 2024  
**Next Review:** After Phase 1 (test coverage) completion

---

## 🎯 Quick Start Checklist

Before you begin ANY refactoring:

- [ ] Read this entire document
- [ ] Understand test-first approach
- [ ] Understand per-module approach
- [ ] Create feature branch
- [ ] Run baseline test suite
- [ ] Start with Phase 1: Write ALL request specs
- [ ] Only proceed to Phase 2 when ALL specs are written and passing