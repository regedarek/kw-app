require 'i18n'
require 'dry-validation'

module Settlement
  ContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:title).filled(:str?)
    required(:cost).filled(:int?)
    required(:description).maybe(:str?)
    required(:attachments).maybe
    required(:users_names).each(:int?)
  end
end
