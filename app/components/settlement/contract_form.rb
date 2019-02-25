  module Settlement
    class ContractForm < Dry::Validation::Schema::Form
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/settlement/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:title).filled
        required(:description).filled
        required(:cost).filled
      end
    end
  end
