require 'i18n'
require 'dry-validation'

module Settlement
  NewContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:title).filled(:str?)
    required(:contractor_id).filled(:int?)
    optional(:group_type).maybe(:str?)
    optional(:bank_account).maybe(:str?)
    optional(:bank_account_owner).maybe(:str?)
    required(:document_number).filled(:str?)
    required(:document_date).filled(:str?)
    optional(:document_type).maybe(:str?)
    optional(:payout_type).maybe(:str?)
    required(:currency_type).filled(:str?)
    required(:cost).filled(:float?)
    required(:description).maybe(:str?)
    optional(:contract_template_id).maybe(:int?)
    required(:user_ids).each(:str?)
    optional(:project_ids).maybe
    optional(:photos_attributes).maybe

    validate(payout_type_presence: [:contract_template_id, :payout_type]) do |contract_template_id, payout_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.payout_type
        true
      else
        !!payout_type
      end
    end

    validate(bank_account_presence: [:bank_account, :payout_type]) do |bank_account, payout_type|
      if payout_type == 'return'
        !!bank_account
      else
        true
      end
    end

    validate(document_type_presence: [:contract_template_id, :document_type]) do |contract_template_id, document_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.document_type
        true
      else
        !!document_type
      end
    end

    validate(document_type_presence: [:contract_template_id, :document_type]) do |contract_template_id, document_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.document_type
        true
      else
        !!document_type
      end
    end

    validate(group_type_presence: [:contract_template_id, :group_type]) do |contract_template_id, group_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.group_type
        true
      else
        !!group_type
      end
    end

    validate(group_type_presence: [:contract_template_id, :group_type]) do |contract_template_id, group_type|
      template = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)

      if template&.group_type
        true
      else
        !!group_type
      end
    end

    validate(nip_if_fv: [:contract_template_id, :contractor_id, :document_type]) do |contract_template_id, contractor_id, document_type|
      document_type_1 = Settlement::ContractTemplateRecord.find_by(id: contract_template_id)&.document_type || document_type

      if ['fv'].include?(document_type_1)
        Settlement::ContractorRecord.find_by(id: contractor_id).nip?
      else
        true
      end
    end

    validate(photos_presence: [:document_type, :photos_attributes]) do |document_type, photos_attributes|
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

    validate(project_presence: [:contract_template_id, :project_ids]) do |contract_template_id, project_ids|
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
