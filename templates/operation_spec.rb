# frozen_string_literal: true

# Template: Operation Spec
# Location: spec/components/{{namespace}}/operation/{{action}}_spec.rb
#
# Replace:
#   {{Namespace}}  → Module name (e.g., Users, Orders)
#   {{Action}}     → Action name (e.g., Create, Update, Delete)
#   {{Resource}}   → Model name (e.g., User, Order)
#   {{resource}}   → snake_case singular (e.g., user, order)

require 'rails_helper'

RSpec.describe {{Namespace}}::Operation::{{Action}} do
  subject(:operation) { described_class.new }

  describe '#call' do
    # === Valid Parameters ===
    let(:valid_params) do
      {
        {{resource}}: {
          name: 'Test Name',
          email: 'test@example.com'
          # Add other required fields
        }
      }
    end

    # === Invalid Parameters ===
    let(:invalid_params) do
      {
        {{resource}}: {
          name: '',
          email: 'invalid-email'
        }
      }
    end

    context 'with valid parameters' do
      subject(:result) { operation.call(params: valid_params) }

      it 'returns Success' do
        expect(result).to be_success
      end

      it 'returns the created {{resource}}' do
        expect(result.success).to be_a(Db::{{Resource}})
      end

      it 'creates a {{resource}}' do
        expect { result }.to change(Db::{{Resource}}, :count).by(1)
      end

      it 'persists the correct attributes' do
        {{resource}} = result.success

        expect({{resource}}.name).to eq('Test Name')
        expect({{resource}}.email).to eq('test@example.com')
      end

      # === Side Effects ===
      # it 'enqueues notification job' do
      #   expect { result }
      #     .to have_enqueued_job({{Resource}}NotificationJob)
      #     .with(kind_of(Integer))
      # end
    end

    context 'with invalid parameters' do
      subject(:result) { operation.call(params: invalid_params) }

      it 'returns Failure' do
        expect(result).to be_failure
      end

      it 'returns validation errors' do
        expect(result.failure).to be_a(Hash)
      end

      it 'includes specific error messages' do
        errors = result.failure

        expect(errors).to have_key(:{{resource}})
        # Or for nested errors:
        # expect(errors[:{{resource}}]).to have_key(:name)
      end

      it 'does not create a {{resource}}' do
        expect { result }.not_to change(Db::{{Resource}}, :count)
      end

      # === No Side Effects ===
      # it 'does not enqueue any jobs' do
      #   expect { result }.not_to have_enqueued_job
      # end
    end

    context 'with missing required fields' do
      subject(:result) { operation.call(params: { {{resource}}: {} }) }

      it 'returns Failure' do
        expect(result).to be_failure
      end
    end

    # === Authorization (if applicable) ===
    # context 'when user is not authorized' do
    #   let(:unauthorized_user) { create(:user, role: :guest) }
    #
    #   subject(:result) do
    #     operation.call(params: valid_params, user: unauthorized_user)
    #   end
    #
    #   it 'returns Failure with unauthorized error' do
    #     expect(result).to be_failure
    #     expect(result.failure).to include(:authorization)
    #   end
    # end

    # === Edge Cases ===
    # context 'when email already exists' do
    #   before { create(:{{resource}}, email: 'test@example.com') }
    #
    #   it 'returns Failure with uniqueness error' do
    #     result = operation.call(params: valid_params)
    #
    #     expect(result).to be_failure
    #     expect(result.failure[:{{resource}}][:email]).to include('has already been taken')
    #   end
    # end
  end
end

# ==============================================================================
# PATTERN MATCHING EXAMPLES
# ==============================================================================
#
# When testing operations with pattern matching in specs:
#
# case result
# in Success({{resource}})
#   expect({{resource}}).to be_persisted
# in Failure(errors)
#   fail "Expected Success, got Failure: #{errors}"
# end
#
# ==============================================================================
# TESTING DIFFERENT FAILURE TYPES
# ==============================================================================
#
# If your operation returns typed failures like Failure([:not_found, message]):
#
# context 'when record not found' do
#   it 'returns :not_found failure' do
#     result = operation.call(id: 99999)
#
#     case result
#     in Failure([:not_found, message])
#       expect(message).to include('not found')
#     else
#       fail "Expected Failure[:not_found], got #{result}"
#     end
#   end
# end
#
# ==============================================================================
# HELPER METHODS
# ==============================================================================
#
# def expect_success_with(result, expected_class: Db::{{Resource}})
#   expect(result).to be_success
#   expect(result.success).to be_a(expected_class)
#   result.success
# end
#
# def expect_failure_with(result, *expected_keys)
#   expect(result).to be_failure
#   expected_keys.each do |key|
#     expect(result.failure).to have_key(key)
#   end
#   result.failure
# end