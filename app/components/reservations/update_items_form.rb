module Reservations
  class UpdateItemsForm < Dry::Validation::Contract
    config.messages.load_paths << 'app/components/training/errors.yml'

    params do
      required(:id).filled(:string)
      required(:items_ids).filled(:string)
    end
  end
end
