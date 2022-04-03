require 'i18n'
require 'dry-validation'

module Settlement
  OfficeKingContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }
    configure do
      option :record
      option :verify
    end

    required(:title).filled(:str?)
    required(:cost).filled(:float?)
    required(:document_type).filled
    required(:payout_type).filled
    required(:internal_number).filled
    required(:document_date).filled(:str?)
    required(:document_number).filled(:str?)
    required(:description).maybe(:str?)
    optional(:document_deliver).maybe
    optional(:accountant_deliver).maybe
    optional(:attachments).maybe
    optional(:photos_attributes).maybe
    optional(:group_type).maybe
    optional(:activity_type).maybe
    optional(:event_type).maybe
    optional(:area_type).maybe
    optional(:acceptor_id).maybe
    optional(:checker_id).maybe
    optional(:closer_id).maybe
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

    validate(accepted_group: [:state, :checker_id]) do |state, checker_id|
      if ['accepted', 'preclosed', 'closed'].include?(state)
        checker_id.present?
      else
        true
      end
    end

    validate(preclosed_group: [:state, :acceptor_id]) do |state, acceptor_id|
      if ['preclosed', 'closed'].include?(state)
        acceptor_id.present?
      else
        true
      end
    end

    validate(accepted_fields: [:activity_type, :group_type, :event_type, :state]) do |activity_type, group_type, event_type, state|
      if ['accepted', 'preclosed', 'closed'].include?(state) || ['accept', 'prepayment'].include?(verify)
        activity_type.present? && group_type.present? && event_type.present?
      else
        true
      end
    end

    validate(closed_fields: [:substantive_type, :financial_type, :area_type, :state]) do |substantive_type, financial_type, area_type, state|
      if ['closed'].include?(state) || ['finish'].include?(verify)
        substantive_type.present? && financial_type.present? && area_type.present?
      else
        true
      end
    end
  end
end
