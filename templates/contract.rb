# frozen_string_literal: true

# Template: Dry::Validation Contract
# Location: app/components/{{namespace}}/contract/{{action}}.rb
# Example:  app/components/users/contract/create.rb
#
# Usage:
#   contract = {{Namespace}}::Contract::{{Action}}.new
#   result = contract.call(params)
#   result.success? # => true/false
#   result.errors.to_h # => { field: ['error message'] }

class {{Namespace}}::Contract::{{Action}} < Dry::Validation::Contract
  # Inject dependencies if needed
  # option :record, default: -> { nil }

  # Define the input schema
  params do
    required(:{{resource}}).hash do
      required(:name).filled(:string)
      required(:email).filled(:string)
      optional(:description).maybe(:string)
      optional(:status).filled(:string)
    end
  end

  # Custom validation rules
  rule(:{{resource}}) do
    if values[:{{resource}}][:email].present?
      unless values[:{{resource}}][:email].match?(URI::MailTo::EMAIL_REGEXP)
        key(:{{resource}}, :email).failure('is not a valid email')
      end
    end
  end

  # Rule with injected dependency
  # rule(:{{resource}}) do
  #   if record && values[:{{resource}}][:name] == record.name
  #     key(:{{resource}}, :name).failure('must be different from current')
  #   end
  # end
end

# =============================================================================
# USAGE IN OPERATION
# =============================================================================
#
# class {{Namespace}}::Operation::{{Action}}
#   include Dry::Monads[:result, :do]
#
#   def call(params:)
#     validated = yield validate!(params)
#     # ... rest of operation
#     Success(result)
#   end
#
#   private
#
#   def validate!(params)
#     contract = {{Namespace}}::Contract::{{Action}}.new
#     result = contract.call(params)
#     result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
#   end
# end
#
# =============================================================================
# WITH INJECTED DEPENDENCY
# =============================================================================
#
# def validate!(params)
#   contract = {{Namespace}}::Contract::{{Action}}.new(record: existing_record)
#   result = contract.call(params)
#   result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
# end
#
# =============================================================================
# COMMON SCHEMA TYPES
# =============================================================================
#
# required(:field).filled(:string)         # Required, non-empty string
# required(:field).filled(:integer)        # Required integer
# required(:field).filled(:decimal)        # Required decimal
# required(:field).filled(:bool)           # Required boolean
# required(:field).filled(:date)           # Required date
# required(:field).filled(:date_time)      # Required datetime
# required(:field).value(:array)           # Required array
# required(:field).filled(:hash)           # Required hash
#
# optional(:field).maybe(:string)          # Optional, can be nil
# optional(:field).filled(:string)         # Optional but non-empty if present
#
# required(:field).filled(:string, min_size?: 2)     # Min length
# required(:field).filled(:string, max_size?: 100)   # Max length
# required(:field).filled(:integer, gt?: 0)          # Greater than
# required(:field).filled(:integer, gteq?: 1)        # Greater than or equal
# required(:field).filled(included_in?: %w[a b c])   # Enum values
#
# =============================================================================
# NESTED SCHEMAS
# =============================================================================
#
# params do
#   required(:user).hash do
#     required(:profile).hash do
#       required(:bio).filled(:string)
#     end
#     required(:addresses).array(:hash) do
#       required(:street).filled(:string)
#       required(:city).filled(:string)
#     end
#   end
# end