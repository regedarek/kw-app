require 'i18n'
require 'dry-validation'

module Settlement
  class OfficeKingContractForm < Dry::Validation::Contract
    config.messages.load_paths << 'app/components/settlement/errors.yml'
    option :record
    option :verify

    params do
    required(:title).filled(:string)
    required(:cost).filled(:float)
    required(:document_type).filled
    required(:payout_type).filled
    required(:internal_number).filled
    required(:document_date).filled(:string)
    required(:document_number).filled(:string)
    required(:description).maybe(:string)
    optional(:document_deliver)
    optional(:accountant_deliver)
    optional(:attachments)
    optional(:photos_attributes)
    optional(:group_type)
    optional(:activity_type)
    optional(:event_type)
    optional(:area_type)
    optional(:acceptor_id)
    optional(:checker_id)
    optional(:closer_id)
    optional(:substantive_type)
    optional(:state)
    optional(:financial_type)
    optional(:period_date)
    required(:user_ids).each(:string)
    optional(:project_ids)
    optional(:contractor_id).maybe(:integer)
    optional(:'period_date(1i)')
    optional(:'period_date(2i)')
    end

    rule(:internal_number, :'period_date(1i)') do |internal_number, period_date|
      record.class.where.not(id: record.id).where(period_date: "01-01-#{period_date}", internal_number: internal_number).empty?
    end

    rule(:state, :checker_id) do |state, checker_id|
      if ['accepted', 'preclosed', 'closed'].include?(state)
        checker_id.present?
      else
        true
      end
    end

    rule(:state, :acceptor_id) do |state, acceptor_id|
      if ['preclosed', 'closed'].include?(state)
        acceptor_id.present?
      else
        true
      end
    end

    rule(:activity_type, :group_type, :event_type, :state) do |activity_type, group_type, event_type, state|
      if ['accepted', 'preclosed', 'closed'].include?(state) || ['accept', 'prepayment'].include?(verify)
        activity_type.present? && group_type.present? && event_type.present?
      else
        true
      end
    end

    rule(:substantive_type, :financial_type, :area_type, :state) do |substantive_type, financial_type, area_type, state|
      if ['closed'].include?(state) || ['finish'].include?(verify)
        substantive_type.present? && financial_type.present? && area_type.present?
      else
        true
      end
    end
  end
end
