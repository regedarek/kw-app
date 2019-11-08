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
        required(:link_payment).filled
      end
    end
  end
end
