module Settlement
  class UpdateContract
    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(id:, raw_inputs:, verify:, updater_id:)
      contract = Settlement::ContractRecord.find(id)
      if Db::User.find_by(id: updater_id)&.roles&.include?('office_king')
        form_outputs = "::Settlement::OfficeKingContractForm".constantize.with(record: contract, verify: verify).call(raw_inputs.to_h)
      else
        form_outputs = "::Settlement::ContractForm".constantize.with(record: contract, verify: verify).call(raw_inputs.to_h)
      end
      return Failure(form_outputs.messages) unless form_outputs.success?

      period_date_month = form_outputs.to_h.delete(:"period_date(2i)").try :to_i
      period_date_year = form_outputs.to_h.delete(:"period_date(1i)").try :to_i
      contract.update(form_outputs.to_h)
      contract.update(
        period_date: Date.civil(period_date_year, period_date_month, 1)
      ) if period_date_month && period_date_year
      contract.update(contractor_id: form_outputs[:contractor_name].first.to_i) if form_outputs.to_h.key?(:contractor_name)

      if form_outputs[:activity_type].present? && form_outputs[:group_type].present? && form_outputs[:event_type].present? && !contract.checker_id && contract.new?
        contract.update(
          checker_id: updater_id, state: 'accepted'
        )
        ::Settlement::ContractMailer.state_changed(contract).deliver_later
      end

      if verify == 'prepayment'
        contract.update(acceptor_id: updater_id, state: 'preclosed')
        ::Settlement::ContractMailer.state_changed(contract).deliver_later
      end

      if verify == 'finish'
        ::Settlement::ContractMailer.state_changed(contract).deliver_later
        contract.update(state: 'closed', closer_id: updater_id)
      end

      unless contract.closed_at.present?
        if form_outputs[:document_deliver] == '1' && form_outputs[:accountant_deliver] == '1'
          contract.update(closed_at: Time.current)
        end if raw_inputs.key?(:document_deliver) && raw_inputs.key?(:accountant_deliver)
      end

      office_king_ids = Db::User.where(":name = ANY(roles)", name: "office_king").map(&:id)
      financial_ids = Db::User.where(":name = ANY(roles)", name: "financial_management").map(&:id)
      contract_user_ids = contract.users.map(&:id)
      recepient_ids = (financial_ids + office_king_ids + contract_user_ids).uniq.reject{|id| id == updater_id }
      recepient_ids.each do |id|
        NotificationCenter::NotificationRecord.create(
          recipient_id: id,
          actor_id: updater_id,
          action: 'updated_contract',
          notifiable_id: contract.id,
          notifiable_type: 'Settlement::ContractRecord'
        )
      end

      Success(contract)
    end

    private

    attr_reader :repository, :form
  end
end
