module Training
  module Supplementary
    class CreatePackageForm < Dry::Validation::Contract
      config.messages.load_paths << 'app/components/training/errors.yml'

      params do
      required(:name).filled(:string)
      required(:cost).filled
      required(:course_id).filled
      end
    end
  end
end
