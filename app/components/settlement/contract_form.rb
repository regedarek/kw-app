  module Settlement
    class ContractForm < Dry::Validation::Schema::Form
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/settlement/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:title).filled
        required(:cost).filled
        required(:users_names).maybe
        optional(:description).maybe
        optional(:attachments).maybe
      end
    end
  end
