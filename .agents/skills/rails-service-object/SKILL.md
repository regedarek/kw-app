---
name: rails-service-object
description: Service object architecture for kw-app using dry-monads Result monad. Covers when to use services, structure patterns, testing, and integration with controllers.
allowed-tools: Read, Write, Edit, Bash
---

# Rails Service Object Pattern (kw-app)

## Overview

Service objects encapsulate complex business logic that doesn't belong in models or controllers.

**kw-app Standard**: All services MUST use dry-monads (`Success`/`Failure`).

## When to Use Service Objects

| Scenario | Use Service Object? | Alternative |
|----------|---------------------|-------------|
| Multiple model interactions | ✅ Yes | - |
| Complex business logic | ✅ Yes | - |
| External API calls | ✅ Yes | - |
| Multi-step operations | ✅ Yes | - |
| Transaction required | ✅ Yes | - |
| Simple CRUD | ❌ No | Use model directly |
| Single validation | ❌ No | Use model validation |
| View formatting | ❌ No | Use presenter/helper |

## Decision Tree

```
Where should this logic go?

Is it business logic?
├─ No → Controller/View/Helper
└─ Yes → Continue...

Does it involve multiple models?
├─ Yes → Service Object
└─ No → Continue...

Is it complex (>10 lines)?
├─ Yes → Service Object
└─ No → Model method

Does it call external APIs?
├─ Yes → Service Object
└─ No → Continue...

Does it need transaction?
├─ Yes → Service Object
└─ No → Model method
```

## Structure

### Naming Convention

```
app/components/
├── users/
│   └── operation/
│       ├── create.rb         # Users::Operation::Create
│       ├── update.rb         # Users::Operation::Update
│       └── activate.rb       # Users::Operation::Activate
└── payments/
    └── operation/
        ├── charge.rb         # Payments::Operation::Charge
        └── refund.rb         # Payments::Operation::Refund
```

**Pattern**: `Namespace::Operation::Action`

### Basic Template

```ruby
# app/components/users/operation/create.rb
module Users
  module Operation
    class Create
      include Dry::Monads[:result, :do]

      def call(params:)
        validated = yield validate(params)
        user      = yield persist(validated)
        
        Success(user)
      end

      private

      def validate(params)
        contract = Users::Contract::Create.new.call(params)
        return Failure(contract.errors.to_h) unless contract.success?
        Success(contract.to_h)
      end

      def persist(attrs)
        user = User.create(attrs)
        user.persisted? ? Success(user) : Failure(user.errors)
      end
    end
  end
end
```

## Patterns

### Pattern 1: Simple CRUD Service

```ruby
module Users
  module Operation
    class Create
      include Dry::Monads[:result, :do]

      def call(params:, current_user:)
        validated = yield validate(params)
        user      = yield persist(validated, current_user)
        yield send_welcome_email(user)
        
        Success(user)
      end

      private

      def validate(params)
        contract = Users::Contract::Create.new.call(params)
        return Failure([:validation_failed, contract.errors.to_h]) unless contract.success?
        Success(contract.to_h)
      end

      def persist(attrs, creator)
        user = User.new(attrs.merge(created_by: creator))
        user.save ? Success(user) : Failure([:save_failed, user.errors])
      end

      def send_welcome_email(user)
        UserMailer.welcome(user).deliver_later
        Success(:email_queued)
      rescue => e
        # Don't fail the whole operation if email fails
        Rails.logger.error("Failed to send welcome email: #{e.message}")
        Success(:email_skipped)
      end
    end
  end
end
```

### Pattern 2: Service with Transaction

```ruby
module Orders
  module Operation
    class Create
      include Dry::Monads[:result, :do]

      def call(user:, cart:)
        return Failure([:empty_cart, "Cart is empty"]) if cart.empty?

        order = nil
        ActiveRecord::Base.transaction do
          order = yield create_order(user, cart)
          yield create_order_items(order, cart)
          yield charge_payment(order, user)
          yield clear_cart(cart)
        end

        Success(order)
      rescue ActiveRecord::RecordInvalid => e
        Failure([:record_invalid, e.message])
      rescue PaymentError => e
        Failure([:payment_failed, e.message])
      end

      private

      def create_order(user, cart)
        order = user.orders.create!(
          total: cart.total,
          status: :pending
        )
        Success(order)
      end

      def create_order_items(order, cart)
        cart.items.each do |item|
          order.order_items.create!(
            product: item.product,
            quantity: item.quantity,
            price: item.price
          )
        end
        Success(order)
      end

      def charge_payment(order, user)
        PaymentGateway.charge(user: user, amount: order.total)
        order.update!(status: :paid)
        Success(order)
      end

      def clear_cart(cart)
        cart.clear!
        Success(:cleared)
      end
    end
  end
end
```

### Pattern 3: Service with Dependencies

```ruby
module Notifications
  module Operation
    class Send
      include Dry::Monads[:result, :do]

      def initialize(notifier: default_notifier, logger: Rails.logger)
        @notifier = notifier
        @logger = logger
      end

      def call(user:, message:)
        return Failure([:disabled, "User has notifications disabled"]) unless user.notifications_enabled?

        result = yield send_notification(user, message)
        yield log_notification(user, result)

        Success(result)
      end

      private

      attr_reader :notifier, :logger

      def default_notifier
        Rails.env.test? ? NullNotifier.new : PushNotifier.new
      end

      def send_notification(user, message)
        notifier.deliver(user: user, message: message)
        Success(:delivered)
      rescue NotificationError => e
        Failure([:delivery_failed, e.message])
      end

      def log_notification(user, result)
        logger.info("Notification sent to user #{user.id}: #{result}")
        Success(:logged)
      end
    end
  end
end
```

### Pattern 4: Calculation Service

```ruby
module Entities
  module Operation
    class CalculateRating
      include Dry::Monads[:result]

      def call(entity:)
        average = calculate_average(entity)
        
        if entity.update(average_rating: average, submissions_count: count_submissions(entity))
          Success(average)
        else
          Failure([:update_failed, entity.errors])
        end
      end

      private

      def calculate_average(entity)
        return 0.0 if entity.submissions.empty?
        entity.submissions.average(:rating).to_f.round(1)
      end

      def count_submissions(entity)
        entity.submissions.count
      end
    end
  end
end
```

## Controller Integration

### Standard Pattern

```ruby
class UsersController < ApplicationController
  def create
    result = Users::Operation::Create.new.call(
      params: user_params,
      current_user: current_user
    )

    case result
    in Success(user)
      redirect_to user, notice: 'User created successfully'
    in Failure([:validation_failed, errors])
      @errors = errors
      render :new, status: :unprocessable_entity
    in Failure([:save_failed, errors])
      @errors = errors
      render :new, status: :unprocessable_entity
    in Failure(error)
      redirect_to users_path, alert: "Error: #{error}"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end
end
```

### With Detailed Error Handling

```ruby
class OrdersController < ApplicationController
  def create
    result = Orders::Operation::Create.new.call(
      user: current_user,
      cart: current_cart
    )

    case result
    in Success(order)
      redirect_to order, notice: 'Order placed successfully'
    in Failure([:empty_cart, message])
      redirect_to cart_path, alert: message
    in Failure([:payment_failed, message])
      flash[:error] = "Payment failed: #{message}"
      render :review, status: :unprocessable_entity
    in Failure([:record_invalid, message])
      flash[:error] = "Order error: #{message}"
      render :review, status: :unprocessable_entity
    in Failure(error)
      Bugsnag.notify(error)
      redirect_to cart_path, alert: 'An error occurred'
    end
  end
end
```

## Testing

### Basic Service Spec

```ruby
# spec/components/users/operation/create_spec.rb
require 'rails_helper'

RSpec.describe Users::Operation::Create do
  subject(:operation) { described_class.new }

  describe '#call' do
    let(:params) { { email: 'test@example.com', name: 'Test' } }
    let(:current_user) { create(:user) }

    context 'with valid params' do
      it 'returns Success with user' do
        result = operation.call(params: params, current_user: current_user)

        expect(result).to be_success
        expect(result.success).to be_a(User)
        expect(result.success.email).to eq('test@example.com')
      end

      it 'creates a user record' do
        expect {
          operation.call(params: params, current_user: current_user)
        }.to change(User, :count).by(1)
      end

      it 'sets created_by' do
        result = operation.call(params: params, current_user: current_user)
        expect(result.success.created_by).to eq(current_user)
      end
    end

    context 'with invalid params' do
      let(:params) { { email: '', name: '' } }

      it 'returns Failure with validation errors' do
        result = operation.call(params: params, current_user: current_user)

        expect(result).to be_failure
        
        case result
        in Failure([:validation_failed, errors])
          expect(errors).to include(:email, :name)
        else
          fail "Expected validation_failed, got #{result}"
        end
      end

      it 'does not create a user' do
        expect {
          operation.call(params: params, current_user: current_user)
        }.not_to change(User, :count)
      end
    end
  end
end
```

### Testing with Mocked Dependencies

```ruby
RSpec.describe Notifications::Operation::Send do
  subject(:operation) { described_class.new(notifier: notifier, logger: logger) }

  let(:notifier) { instance_double(PushNotifier) }
  let(:logger) { instance_double(Logger) }
  let(:user) { create(:user, notifications_enabled: true) }
  let(:message) { 'Test notification' }

  before do
    allow(notifier).to receive(:deliver).and_return(true)
    allow(logger).to receive(:info)
  end

  describe '#call' do
    it 'sends notification' do
      result = operation.call(user: user, message: message)

      expect(result).to be_success
      expect(notifier).to have_received(:deliver).with(user: user, message: message)
    end

    context 'when notification fails' do
      before do
        allow(notifier).to receive(:deliver).and_raise(NotificationError, 'Network error')
      end

      it 'returns Failure' do
        result = operation.call(user: user, message: message)

        expect(result).to be_failure
        
        case result
        in Failure([:delivery_failed, message])
          expect(message).to eq('Network error')
        else
          fail "Expected delivery_failed, got #{result}"
        end
      end
    end
  end
end
```

### Testing Transactions

```ruby
RSpec.describe Orders::Operation::Create do
  subject(:operation) { described_class.new }

  let(:user) { create(:user) }
  let(:cart) { create(:cart, :with_items, user: user) }

  describe '#call' do
    context 'when payment fails' do
      before do
        allow(PaymentGateway).to receive(:charge).and_raise(PaymentError, 'Card declined')
      end

      it 'does not create order (rollback)' do
        expect {
          operation.call(user: user, cart: cart)
        }.not_to change(Order, :count)
      end

      it 'does not clear cart (rollback)' do
        expect {
          operation.call(user: user, cart: cart)
        }.not_to change { cart.reload.items.count }
      end

      it 'returns Failure' do
        result = operation.call(user: user, cart: cart)

        expect(result).to be_failure
        
        case result
        in Failure([:payment_failed, message])
          expect(message).to include('Card declined')
        else
          fail "Expected payment_failed, got #{result}"
        end
      end
    end
  end
end
```

## Best Practices

### ✅ Always Do

- Use dry-monads `Success`/`Failure`
- Use do-notation for chaining
- Write comprehensive tests
- Follow single responsibility
- Use dependency injection
- Handle all error cases
- Use descriptive failure codes

### ⚠️ Ask First

- Modifying existing services used by multiple controllers
- Adding external API dependencies
- Changing service interfaces
- Adding database transactions

### 🚫 Never Do

- Mix exceptions with monads
- Create services without tests
- Put presentation logic in services
- Use custom Result classes (deprecated)
- Skip error handling
- Create "god" services with too many responsibilities

## Common Mistakes

### ❌ Mistake 1: Not using :do notation

```ruby
# ❌ Wrong - verbose
def call(params:)
  validation_result = validate(params)
  return validation_result if validation_result.failure?
  
  persist_result = persist(validation_result.success)
  return persist_result if persist_result.failure?
  
  persist_result
end
```

**Fix:**
```ruby
# ✅ Correct - clean with :do
def call(params:)
  validated = yield validate(params)
  user      = yield persist(validated)
  Success(user)
end
```

### ❌ Mistake 2: Returning different types

```ruby
# ❌ Wrong - inconsistent returns
def call(params:)
  return false unless valid?(params)  # Returns boolean
  Success(create_user(params))         # Returns monad
end
```

**Fix:**
```ruby
# ✅ Correct - always return monad
def call(params:)
  return Failure(:invalid) unless valid?(params)
  Success(create_user(params))
end
```

### ❌ Mistake 3: Too many responsibilities

```ruby
# ❌ Wrong - god service
class Users::Process
  def call
    # Validates
    # Creates user
    # Sends email
    # Updates stats
    # Logs analytics
    # Notifies admin
    # ... 500 more lines
  end
end
```

**Fix:**
```ruby
# ✅ Correct - split responsibilities
class Users::Operation::Create
  def call
    user = yield create_user
    yield Users::Operation::SendWelcomeEmail.new.call(user: user)
    yield Users::Operation::UpdateStats.new.call(user: user)
    Success(user)
  end
end
```

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Simple do-notation | Multi-step success path | User creation |
| With transaction | Multi-model changes | Order processing |
| With dependencies | External services | Notifications |
| Calculation | Data transformation | Rating calculation |

## Additional Resources

- **dry-monads patterns**: See [dry-monads-patterns skill](../dry-monads-patterns/SKILL.md)
- **Testing standards**: See [testing-standards skill](../testing-standards/SKILL.md)
- **kw-app policy**: See CLAUDE.md section on services
- **Official dry-rb**: https://dry-rb.org/gems/dry-monads/

---

**Version**: 2.0  
**Last Updated**: 2024-01  
**Maintained By**: kw-app team