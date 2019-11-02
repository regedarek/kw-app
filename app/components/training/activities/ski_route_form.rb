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
        required(:colleague_ids).filled
        optional(:rating).filled
        optional(:partners)
        optional(:difficulty)
        optional(:area)
        optional(:length)
        optional(:description)
        optional(:contract_ids)
      end
    end
  end
end
