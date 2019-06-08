require 'i18n'
require 'dry-validation'

module Settlement
  ContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:title).filled(:str?)
    required(:cost).filled(:float?)
    required(:document_type).filled
    required(:payout_type).filled
    required(:document_date).filled(:str?)
    required(:description).maybe(:str?)
    optional(:attachments).maybe
    optional(:group_type).maybe
    optional(:acceptor_id).maybe
    optional(:substantive_type).maybe
    optional(:state).maybe
    optional(:financial_type).maybe
    optional(:period_date).maybe
    required(:users_names).each(:int?)
    optional(:events_names).maybe
    optional(:contractor_name).maybe
    optional(:event_id).maybe
    optional(:'period_date(1i)').maybe
    optional(:'period_date(2i)').maybe
  end
end
