module Training
  module Supplementary
    class CreatePackageForm < Dry::Validation::Schema
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:name).filled(:str?)
        required(:cost).filled
        required(:course_id).filled
      end
    end
  end
end
