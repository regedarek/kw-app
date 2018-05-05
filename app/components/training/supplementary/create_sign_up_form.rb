module Training
  module Supplementary
    class CreateSignUpForm < Dry::Validation::Schema::Form
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:email).filled(:str?)
      end
    end
  end
end
