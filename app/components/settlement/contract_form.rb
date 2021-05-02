require 'i18n'
require 'dry-validation'

module Settlement
  ContractForm = Dry::Validation.Params do
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
    required(:document_date).filled(:str?)
    required(:document_number).filled(:str?)
    required(:description).maybe(:str?)
    optional(:attachments).maybe
    optional(:photos_attributes).maybe
    optional(:group_type).maybe
    optional(:activity_type).maybe
    optional(:event_type).maybe
    optional(:area_type).maybe
    optional(:acceptor_id).maybe
    optional(:checker_id).maybe
    optional(:substantive_type).maybe
    optional(:state).maybe
    optional(:financial_type).maybe
    optional(:period_date).maybe
    optional(:project_ids).maybe
    optional(:contractor_id).maybe(:int?)
    optional(:'period_date(1i)').maybe
    optional(:'period_date(2i)').maybe

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

    validate(accepted_fields: [:activity_type, :group_type, :event_type, :state, :project_ids]) do |activity_type, group_type, event_type, state, project_ids|
      if ['accepted', 'preclosed', 'closed'].include?(state) || ['accept', 'prepayment'].include?(verify)
        if activity_type.present? && group_type.present? && event_type.present?
          if ['supplementary_trainings', 'courses'].include?(activity_type)
            if project_ids.reject(&:empty?).any?
              true
            else
              false
            end
          else
            true
          end
        else
          false
        end
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
