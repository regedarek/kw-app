module Training
  module Supplementary
    class ManuallySignUpForm < Dry::Validation::Contract
      config.messages.load_paths << 'app/components/training/errors.yml'

        params do
        required(:email).filled(:string)
        required(:link_payment).filled
        end
    end
  end
end
