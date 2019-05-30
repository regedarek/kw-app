require 'i18n'
require 'dry-validation'

module Settlement
  ContractorForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:name).filled
    optional(:nip).maybe
    optional(:description).maybe
  end
end
