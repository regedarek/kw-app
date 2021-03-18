require 'i18n'
require 'dry-validation'

module Settlement
  ContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }
    configure do
      option :record
    end

    required(:title).filled(:str?)
    required(:cost).filled(:float?)
    required(:document_type).filled
    required(:payout_type).filled
    required(:internal_number).filled
    required(:document_date).filled(:str?)
    required(:document_number).filled(:str?)
    required(:description).maybe(:str?)
    optional(:attachments).maybe
    optional(:group_type).maybe
    optional(:event_type).maybe
    optional(:area_type).maybe
    optional(:acceptor_id).maybe
    optional(:substantive_type).maybe
    optional(:state).maybe
    optional(:financial_type).maybe
    optional(:period_date).maybe
    required(:user_ids).each(:str?)
    optional(:project_ids).maybe
    optional(:contractor_id).maybe(:int?)
    optional(:'period_date(1i)').maybe
    optional(:'period_date(2i)').maybe

    validate(internal_number_uniq: [:internal_number, :'period_date(1i)']) do |internal_number, period_date|
      record.class.where.not(id: record.id).where(period_date: "01-01-#{period_date}", internal_number: internal_number).empty?
    end
  end
end
