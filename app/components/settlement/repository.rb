module Settlement
  class Repository
    def create_contract(form_outputs:, creator_id:)
      contract = ::Settlement::ContractRecord.new(form_outputs.to_h.merge(creator_id: creator_id))
      if contract.contract_template
        contract.group_type = contract.group_type || contract.contract_template.group_type
        contract.payout_type = contract.payout_type || contract.contract_template.payout_type
        contract.financial_type = contract.contract_template.financial_type
        contract.document_type = contract.document_type || contract.contract_template.document_type
        contract.event_type = contract.contract_template.event_type
        contract.substantive_type = contract.contract_template.substantive_type
        contract.description = contract.contract_template.description
        contract.area_type = contract.contract_template.area_type
        contract.activity_type = contract.contract_template.activity_type
        contract.project_ids = [contract.contract_template.project_id] if contract.contract_template.project_id
        if contract.contract_template.checker_id
          contract.checker_id = contract.contract_template.checker_id
          contract.state = 'accepted'
        end
      end
      year_date = Date.new(contract.document_date.year, 1, 1)
      contract.period_date = year_date
      contract.internal_number = Settlement::ContractRecord.where(period_date: year_date).maximum(:internal_number).to_i + 1
      contract.save!
      contract
    end

    def create_contractor(form_outputs:)
      Settlement::ContractorRecord.create!(form_outputs.to_h)
    end
  end
end
