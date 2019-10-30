module Training
  module Activities
    class SkiRouteForm < Dry::Validation::Schema
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.namespace = :ski_route
      end

      define! do
        required(:name).filled(:str?)
        required(:climbing_date).filled
        required(:rating).filled
        optional(:colleague_ids).maybe
        optional(:contract_ids).maybe
      end
    end
  end
end
