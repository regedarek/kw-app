module Reservations
  class UpdateItemsForm < Dry::Validation::Schema
    configure do
      config.messages = :i18n
      config.messages_file = 'app/components/training/errors.yml'
      config.type_specs = true
    end

    define! do
      required(:id).filled(:str?)
      required(:items_ids).filled(:str?)
    end
  end
end
