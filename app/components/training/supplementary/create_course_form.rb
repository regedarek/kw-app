module Training
  module Supplementary
    class CreateCourseForm < Dry::Validation::Schema::Form
      configure do
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:name).filled(:str?)
        required(:place).filled(:str?)
        optional(:organizator_id).maybe
      end
    end
  end
end
