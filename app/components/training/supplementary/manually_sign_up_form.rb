module Training
  module Supplementary
    class ManuallySignUpForm < Dry::Validation::Schema
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
