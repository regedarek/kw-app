require 'i18n'
require 'dry-validation'

module Settlement
  ContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:title).filled(:str?)
    required(:cost).filled(:float?)
    required(:document_type).filled
    required(:document_date).filled(:str?)
    required(:description).maybe(:str?)
    optional(:attachments).maybe
    optional(:group_type).maybe
    required(:users_names).each(:int?)
  end
end
