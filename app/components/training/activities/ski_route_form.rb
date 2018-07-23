module Training
  module Activities
    class SkiRouteForm < Dry::Validation::Schema::Form
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:name).filled(:str?)
        required(:climbing_date).filled
        required(:rating).filled
      end
    end
  end
end
