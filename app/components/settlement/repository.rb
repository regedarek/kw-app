module Settlement
  class Repository
    def create_contract(form_outputs:, creator_id:)
      contract = ::Settlement::ContractRecord.new(form_outputs.to_h.merge(creator_id: creator_id))
      year_date = Date.new(contract.document_date.year, 1, 1)
      contract.period_date = year_date
      contract.internal_number = Settlement::ContractRecord.where(period_date: year_date).maximum(:internal_number).to_i + 1
      contract.save
      contract
    end

    def create_contractor(form_outputs:)
      Settlement::ContractorRecord.create!(form_outputs.to_h)
    end
  end
end
