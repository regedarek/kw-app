module Settlement
  class ContractForm < Dry::Validation::Contract
    config.messages.load_paths << 'app/components/settlement/errors.yml'

    option :record
    option :verify

    params do
    required(:title).filled(:string)
    required(:cost).filled(:float)
    required(:document_type).filled
    required(:payout_type).filled
    required(:currency_type).filled
    required(:document_date).filled(:string)
    required(:document_number).filled(:string)
    required(:description).maybe(:string)
    optional(:attachments)
    optional(:photos_attributes)
    optional(:group_type)
    optional(:activity_type)
    optional(:event_type)
    optional(:area_type)
    optional(:document_deliver)
    optional(:accountant_deliver)
    optional(:acceptor_id)
    optional(:checker_id)
    optional(:closer_id)
    optional(:substantive_type)
    optional(:state)
    optional(:financial_type)
    optional(:period_date)
    optional(:project_ids)
    optional(:contractor_id).maybe(:integer)
    optional(:'period_date(1i)')
    optional(:'period_date(2i)')
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

    rule(:activity_type, :group_type, :event_type, :state, :project_ids) do |activity_type, group_type, event_type, state, project_ids|
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

    rule(:substantive_type, :financial_type, :area_type, :state) do |substantive_type, financial_type, area_type, state|
      if ['closed'].include?(state) || ['finish'].include?(verify)
        substantive_type.present? && financial_type.present? && area_type.present?
      else
        true
      end
    end
  end
end
