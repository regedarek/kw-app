module Settlement
  class NewContractForm < Dry::Validation::Contract
    config.messages.load_paths << 'app/components/settlement/errors.yml'

    params do
    required(:title).filled(:string)
    required(:contractor_id).filled(:integer)
    optional(:group_type).maybe(:string)
    optional(:bank_account).maybe(:string)
    optional(:bank_account_owner).maybe(:string)
    required(:document_number).filled(:string)
    required(:document_date).filled(:string)
    optional(:document_type).maybe(:string)
    optional(:payout_type).maybe(:string)
    required(:currency_type).filled(:string)
    required(:cost).filled(:float)
    required(:description).maybe(:string)
    optional(:contract_template_id).maybe(:integer)
    required(:user_ids).each(:string)
    optional(:project_ids)
    optional(:photos_attributes)
    end

    rule(:contract_template_id, :payout_type) do |contract_template_id, payout_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.payout_type
        true
      else
        !!payout_type
      end
    end

    rule(:bank_account, :payout_type) do |bank_account, payout_type|
      if payout_type == 'return'
        !!bank_account
      else
        true
      end
    end

    rule(:contract_template_id, :document_type) do |contract_template_id, document_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.document_type
        true
      else
        !!document_type
      end
    end

    rule(:contract_template_id, :document_type) do |contract_template_id, document_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.document_type
        true
      else
        !!document_type
      end
    end

    rule(:contract_template_id, :group_type) do |contract_template_id, group_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.group_type
        true
      else
        !!group_type
      end
    end

    rule(:contract_template_id, :group_type) do |contract_template_id, group_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.group_type
        true
      else
        !!group_type
      end
    end

    rule(:contract_template_id, :contractor_id, :document_type) do |contract_template_id, contractor_id, document_type|
      document_type_1 = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)&.document_type || document_type

      if ['fv'].include?(document_type_1)
        Settlement::ContractorRecord.find_by(id: contractor_id).nip?
      else
        true
      end
    end

    rule(:document_type, :photos_attributes) do |document_type, photos_attributes|
      if ['charities'].include?(document_type)
        true
      else
        if photos_attributes
          photos_attributes.reject(&:empty?).any?
        else
          false
        end
      end
    end

    rule(:contract_template_id, :project_ids) do |contract_template_id, project_ids|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template
        if template.project?
          project_ids.reject(&:empty?).any?
        else
          true
        end
      else
        true
      end
    end
  end
end
