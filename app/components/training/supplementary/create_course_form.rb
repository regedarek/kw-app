module Training
  module Supplementary
    class CreateCourseForm < Dry::Validation::Schema
      configure do
        option :record
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
        config.namespace = :course
      end

      define! do
        required(:name).filled(:str?)
        required(:place).filled(:str?)
        optional(:email_remarks).maybe(:str?)
        optional(:paid_email).maybe(:str?)
        optional(:question).maybe(:str?)
        optional(:send_manually).maybe(:str?)
        required(:payment_type).filled
      end
    end
  end
end
