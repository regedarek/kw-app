# PaymentsController ArgumentError Fix

## Problem
`ArgumentError: unknown keyword: :body` in `PaymentsController#charge` at line 73.

## Root Cause
The `Payments::Dotpay::PaymentRequest` service was creating a `Failure` object with both `message:` and `body:` keyword arguments:

```ruby
Failure.new(:dotpay_request_error, { message: '...', body: JSON.parse(response.body) })
```

However, the controller block only accepted the `message:` keyword:

```ruby
result.dotpay_request_error { |message:| redirect_to root_path, alert: message }
```

When the Result class tried to pass all hash keys as keyword arguments to the block, Ruby 3.2.2's strict keyword argument handling raised `ArgumentError: unknown keyword: :body`.

## Solution
Removed the unused `body:` parameter from the Failure creation in `app/services/payments/dotpay/payment_request.rb`:

**Before:**
```ruby
Failure.new(:dotpay_request_error, { message: '...', body: JSON.parse(response.body) })
```

**After:**
```ruby
Failure.new(:dotpay_request_error, { message: '...' })
```

Also updated the `:wrong_payment_url` failure for consistency:
```ruby
Failure.new(:wrong_payment_url, { message: '...' })
```

## Files Changed
- `app/services/payments/dotpay/payment_request.rb` - Removed `body:` parameter from Failure objects
- `spec/requests/payments_controller_spec.rb` - Added comprehensive tests

## Tests
Created controller specs verifying:
- ✅ Successful payment redirects to payment URL
- ✅ Wrong payment URL errors are handled correctly
- ✅ Dotpay request errors are handled without ArgumentError
- ✅ Extra keyword arguments would raise ArgumentError (demonstrating the bug)

All tests pass. Run: `bundle exec rspec spec/requests/payments_controller_spec.rb`

## Note
The `body` data wasn't being used by the controller anyway - it was only showing a generic error message. Removing it simplified the code without losing functionality.