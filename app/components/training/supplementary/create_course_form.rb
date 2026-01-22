module Training
  module Supplementary
    class CreateCourseForm < Dry::Validation::Contract
        option :record, default: -> { nil }
        config.messages.load_paths << 'app/components/training/errors.yml'
        config.messages.namespace = :course

        params do
        required(:name).filled(:string)
        required(:place).filled(:string)
        optional(:email_remarks).maybe(:string)
        optional(:paid_email).maybe(:string)
        optional(:questringion).maybe(:string)
        optional(:send_manually).maybe(:string)
        required(:payment_type).filled
        end
      end
  end
end
