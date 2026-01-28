# frozen_string_literal: true

# Template: Operation (dry-monads)
#
# Usage:
#   1. Copy this file to app/components/{{namespace}}/operation/{{action}}.rb
#   2. Replace {{Namespace}} with your module (e.g., Users, Orders)
#   3. Replace {{Action}} with your action (e.g., Create, Update, Delete)
#   4. Implement private methods
#
# Example:
#   app/components/users/operation/create.rb
#   Users::Operation::Create

class {{Namespace}}::Operation::{{Action}}
  include Dry::Monads[:result, :do]

  # Main entry point
  #
  # @param params [Hash] Input parameters
  # @return [Dry::Monads::Result] Success(value) or Failure(error)
  def call(params:)
    validated = yield validate!(params)
    record    = yield persist!(validated)
    _         = yield notify!(record)

    Success(record)
  end

  private

  # Validate input parameters
  #
  # @param params [Hash] Raw input
  # @return [Dry::Monads::Result] Success(validated_hash) or Failure(errors)
  def validate!(params)
    contract = {{Namespace}}::Contract::{{Action}}.new.call(params)

    if contract.success?
      Success(contract.to_h)
    else
      Failure(contract.errors.to_h)
    end
  end

  # Persist to database
  #
  # @param attrs [Hash] Validated attributes
  # @return [Dry::Monads::Result] Success(record) or Failure(errors)
  def persist!(attrs)
    record = Db::{{Resource}}.new(attrs)

    if record.save
      Success(record)
    else
      Failure(record.errors.to_h)
    end
  end

  # Optional: Trigger side effects (notifications, jobs, etc.)
  #
  # @param record [Db::{{Resource}}] The persisted record
  # @return [Dry::Monads::Result] Success
  def notify!(record)
    # Example: Enqueue background job
    # {{Resource}}NotificationJob.perform_later(record.id)

    Success(record)
  end
end