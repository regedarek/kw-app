module Settlement
  class Repository
    def create_contract(form_outputs:, creator_id:)
      contract = ::Settlement::ContractRecord.new(form_outputs.to_h.merge(creator_id: creator_id))
      contract.save
      contract
    end

    def create_contractor(form_outputs:)
      Settlement::ContractorRecord.create!(form_outputs.to_h)
    end
  end
end
