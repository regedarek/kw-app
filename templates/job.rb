# frozen_string_literal: true

# Template: Background Job
#
# Usage:
#   1. Copy this file to app/jobs/{{resource}}_{{action}}_job.rb
#   2. Replace {{Resource}} with actual class name (e.g., User)
#   3. Replace {{resource}} with lowercase name (e.g., user)
#   4. Replace {{Action}} with action name (e.g., Notification)
#   5. Implement the perform method
#
# Example:
#   {{Resource}}{{Action}}Job → UserNotificationJob
#   app/jobs/user_notification_job.rb

class {{Resource}}{{Action}}Job < ApplicationJob
  queue_as :default

  # Retry on transient errors
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 5

  # Discard on permanent errors
  discard_on ActiveJob::DeserializationError

  # @param {{resource}}_id [Integer] ID of the {{Resource}} to process
  # @param options [Hash] Additional options
  def perform({{resource}}_id, options = {})
    {{resource}} = Db::{{Resource}}.find_by(id: {{resource}}_id)
    return unless {{resource}}

    # TODO: Implement job logic
    #
    # Examples:
    #
    # Send email:
    #   {{Resource}}Mailer.action({{resource}}).deliver_now
    #
    # Call operation:
    #   {{Resources}}::Operation::Process.new.call({{resource}}: {{resource}})
    #
    # Log with AppSignal:
    #   Appsignal.instrument('{{resource}}.{{action}}') do
    #     process_{{resource}}({{resource}})
    #   end
  end

  private

  # Add private helper methods here
  #
  # def process_{{resource}}({{resource}})
  #   # Implementation
  # end
end

# ==============================================================================
# Spec Template (spec/jobs/{{resource}}_{{action}}_job_spec.rb)
# ==============================================================================
#
# RSpec.describe {{Resource}}{{Action}}Job, type: :job do
#   describe '#perform' do
#     let(:{{resource}}) { create(:{{resource}}) }
#
#     context 'when {{resource}} exists' do
#       it 'processes the {{resource}}' do
#         # TODO: Add expectations
#         expect { described_class.perform_now({{resource}}.id) }
#           .not_to raise_error
#       end
#     end
#
#     context 'when {{resource}} does not exist' do
#       it 'does not raise error' do
#         expect { described_class.perform_now(99999) }
#           .not_to raise_error
#       end
#     end
#   end
#
#   describe 'enqueueing' do
#     it 'enqueues the job' do
#       expect { described_class.perform_later(1) }
#         .to have_enqueued_job(described_class)
#         .with(1)
#         .on_queue('default')
#     end
#   end
# end
# ==============================================================================

# ==============================================================================
# Usage in Operation
# ==============================================================================
#
# class {{Resources}}::Operation::Create
#   include Dry::Monads[:result, :do]
#
#   def call(params:)
#     {{resource}} = yield persist!(params)
#     _            = yield enqueue_{{action}}!({{resource}})
#
#     Success({{resource}})
#   end
#
#   private
#
#   def enqueue_{{action}}!({{resource}})
#     {{Resource}}{{Action}}Job.perform_later({{resource}}.id)
#     Success({{resource}})
#   end
# end
# ==============================================================================