---
name: dry-monads-patterns
description: kw-app mandatory pattern for service objects using dry-monads Result monad with Success/Failure and do-notation. Replaces deprecated custom Result classes.
allowed-tools: Read, Write, Edit, Bash
---

# Dry-Monads Patterns (kw-app Standard)

## Overview

**Status**: MANDATORY for all new service objects in kw-app  
**Replaces**: Custom `Result`, `Success`, `Failure` classes (DEPRECATED)

dry-monads provides railway-oriented programming with `Success` and `Failure` monads, enabling clean error handling without exceptions.

## Why We Use dry-monads

- ✅ **Explicit success/failure paths** - No hidden control flow
- ✅ **Composable operations** - Chain operations with `do` notation
- ✅ **Type safety** - Clear contracts for success/failure data
- ✅ **Industry standard** - Well-maintained, battle-tested gem
- ✅ **Pattern matching** - Ruby 3+ pattern matching support

## Installation

Already in Gemfile:

```ruby
gem 'dry-monads', '~> 1.6'
```

## Basic Pattern

### Include the Monad

```ruby
class Users::Operation::Create
  include Dry::Monads[:result, :do]
  
  def call(params:)
    # Your implementation
  end
end
```

**What this gives you:**
- `Success(value)` - Wrap successful results
- `Failure(error)` - Wrap failures
- `yield` - Unwrap Success, short-circuit on Failure (do-notation)

## Core Patterns

### Pattern 1: Simple Success/Failure

```ruby
class Users::Operation::Activate
  include Dry::Monads[:result]
  
  def call(user_id:)
    user = User.find_by(id: user_id)
    return Failure(:user_not_found) unless user
    
    user.update!(active: true)
    Success(user)
  rescue ActiveRecord::RecordInvalid => e
    Failure([:validation_failed, e.message])
  end
end

# Usage
result = Users::Operation::Activate.new.call(user_id: 123)

case result
in Success(user)
  puts "Activated: #{user.email}"
in Failure(:user_not_found)
  puts "User not found"
in Failure([:validation_failed, message])
  puts "Error: #{message}"
end
```

### Pattern 2: Do-Notation (Railway Pattern)

**Best for chaining multiple operations:**

```ruby
class Users::Operation::Create
  include Dry::Monads[:result, :do]
  
  def call(params:)
    validated = yield validate(params)
    user      = yield persist(validated)
    _sent     = yield send_welcome_email(user)
    
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
  
  def send_welcome_email(user)
    UserMailer.welcome(user).deliver_later
    Success(:email_queued)
  rescue => e
    Failure([:email_failed, e.message])
  end
end
```

**How `yield` works:**
- If result is `Success(value)`, extracts `value` and continues
- If result is `Failure(error)`, immediately returns `Failure(error)` (short-circuit)

### Pattern 3: Multiple Failure Types

```ruby
class Payments::Operation::Charge
  include Dry::Monads[:result, :do]
  
  def call(user_id:, amount:)
    user         = yield find_user(user_id)
    payment_info = yield fetch_payment_info(user)
    charge       = yield process_charge(payment_info, amount)
    
    Success(charge)
  end
  
  private
  
  def find_user(user_id)
    user = User.find_by(id: user_id)
    user ? Success(user) : Failure([:not_found, "User #{user_id} not found"])
  end
  
  def fetch_payment_info(user)
    return Failure([:no_payment_method, "User has no payment method"]) if user.payment_methods.empty?
    Success(user.payment_methods.first)
  end
  
  def process_charge(payment_info, amount)
    return Failure([:invalid_amount, "Amount must be positive"]) if amount <= 0
    
    charge = PaymentGateway.charge(payment_info, amount)
    Success(charge)
  rescue PaymentGateway::Error => e
    Failure([:gateway_error, e.message])
  end
end

# Usage with pattern matching
result = Payments::Operation::Charge.new.call(user_id: 1, amount: 100)

case result
in Success(charge)
  redirect_to charge, notice: "Payment processed"
in Failure([:not_found, message])
  render_error(message, status: :not_found)
in Failure([:no_payment_method, message])
  redirect_to add_payment_path, alert: message
in Failure([:invalid_amount, message])
  render_error(message, status: :unprocessable_entity)
in Failure([:gateway_error, message])
  render_error("Payment failed: #{message}", status: :bad_gateway)
end
```

## Controller Integration

### Standard Pattern

```ruby
class UsersController < ApplicationController
  def create
    result = Users::Operation::Create.new.call(params: user_params)
    
    case result
    in Success(user)
      redirect_to user, notice: 'User created successfully'
    in Failure(errors)
      @errors = errors
      render :new, status: :unprocessable_entity
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
class PaymentsController < ApplicationController
  def create
    result = Payments::Operation::Charge.new.call(
      user_id: current_user.id,
      amount: params[:amount]
    )
    
    case result
    in Success(charge)
      redirect_to charge, notice: "Payment successful"
    in Failure([:not_found, message])
      render json: { error: message }, status: :not_found
    in Failure([:no_payment_method, _])
      redirect_to add_payment_path, alert: "Please add a payment method"
    in Failure([:invalid_amount, message])
      render json: { error: message }, status: :unprocessable_entity
    in Failure([:gateway_error, message])
      Bugsnag.notify(message) # Log to error tracker
      render json: { error: "Payment failed" }, status: :bad_gateway
    end
  end
end
```

## Testing Patterns

### Basic Spec

```ruby
RSpec.describe Users::Operation::Create do
  subject(:operation) { described_class.new }
  
  describe '#call' do
    context 'with valid params' do
      let(:params) { { email: 'test@example.com', name: 'Test' } }
      
      it 'returns Success with user' do
        result = operation.call(params: params)
        
        expect(result).to be_success
        expect(result.success).to be_a(User)
        expect(result.success.email).to eq('test@example.com')
      end
    end
    
    context 'with invalid params' do
      let(:params) { { email: '', name: '' } }
      
      it 'returns Failure with errors' do
        result = operation.call(params: params)
        
        expect(result).to be_failure
        expect(result.failure).to include(:email, :name)
      end
    end
  end
end
```

### Pattern Matching in Specs

```ruby
RSpec.describe Payments::Operation::Charge do
  subject(:operation) { described_class.new }
  
  describe '#call' do
    let(:user) { create(:user, :with_payment_method) }
    
    context 'successful charge' do
      it 'returns Success with charge' do
        result = operation.call(user_id: user.id, amount: 100)
        
        case result
        in Success(charge)
          expect(charge.amount).to eq(100)
        else
          fail "Expected Success, got #{result}"
        end
      end
    end
    
    context 'user not found' do
      it 'returns Failure with not_found code' do
        result = operation.call(user_id: 99999, amount: 100)
        
        case result
        in Failure([:not_found, message])
          expect(message).to include("User 99999 not found")
        else
          fail "Expected Failure[:not_found], got #{result}"
        end
      end
    end
  end
end
```

## Migration from Custom Result Classes

### ❌ Old Pattern (DEPRECATED)

```ruby
require 'result'  # Custom class - DON'T USE

class Users::SomeService
  def call
    return Failure(:invalid, errors: {}) unless valid?
    Success(:success)
  end
end
```

### ✅ New Pattern (CURRENT)

```ruby
class Users::Operation::SomeOperation
  include Dry::Monads[:result, :do]
  
  def call
    return Failure([:invalid, {}]) unless valid?
    Success(:success)
  end
end
```

## Common Mistakes

### ❌ Mistake 1: Not including :do

```ruby
class MyOperation
  include Dry::Monads[:result]  # Missing :do
  
  def call
    user = yield find_user  # ERROR: yield without :do notation
    Success(user)
  end
end
```

**Fix:**

```ruby
class MyOperation
  include Dry::Monads[:result, :do]  # Include :do
  
  def call
    user = yield find_user
    Success(user)
  end
end
```

### ❌ Mistake 2: Mixing exceptions with monads

```ruby
def call
  user = yield find_user
  raise "Invalid user" unless user.valid?  # BAD: mixing paradigms
  Success(user)
end
```

**Fix:**

```ruby
def call
  user = yield find_user
  return Failure(:invalid_user) unless user.valid?
  Success(user)
end
```

### ❌ Mistake 3: Not handling Failure in controller

```ruby
# BAD: Assumes always success
def create
  result = MyOperation.new.call(params: params)
  redirect_to result.success  # Crashes on Failure!
end
```

**Fix:**

```ruby
def create
  result = MyOperation.new.call(params: params)
  
  case result
  in Success(data)
    redirect_to data
  in Failure(error)
    render :new, alert: error
  end
end
```

## Quick Reference

| Operation | Code | Returns |
|-----------|------|---------|
| Wrap success | `Success(value)` | `Success<T>` |
| Wrap failure | `Failure(error)` | `Failure<E>` |
| Check if success | `result.success?` | `true/false` |
| Check if failure | `result.failure?` | `true/false` |
| Unwrap success | `result.success` or `result.value!` | `T` or raises |
| Unwrap failure | `result.failure` or `result.error` | `E` or raises |
| Chain operations | `yield result` | Unwrap or short-circuit |

## Decision Tree

```
Should I use dry-monads for this?
├─ Is it a service object? → YES, use dry-monads
├─ Complex business logic with multiple steps? → YES, use dry-monads with :do
├─ Simple model method? → NO, use standard Ruby
└─ Controller action? → NO, but call operations that use dry-monads
```

## References

- **Official docs**: https://dry-rb.org/gems/dry-monads/
- **kw-app policy**: See CLAUDE.md section on dry-monads
- **Migration guide**: See KNOWN_ISSUES.md for legacy Result classes

---

**Status**: MANDATORY  
**Version**: 2.0  
**Last Updated**: 2024-01