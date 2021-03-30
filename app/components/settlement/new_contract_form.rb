require 'i18n'
require 'dry-validation'

module Settlement
  NewContractForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:title).filled(:str?)
    required(:contractor_id).filled(:int?)
    required(:group_type).filled
    required(:event_type).filled
    required(:document_number).filled(:str?)
    required(:document_date).filled(:str?)
    required(:document_type).filled
    required(:payout_type).filled
    required(:cost).filled(:float?)
    required(:description).maybe(:str?)
    required(:user_ids).each(:str?)
    required(:photos_attributes).filled

    validate(nip_if_fv: [:contractor_id, :document_type]) do |contractor_id, document_type|
      if ['fv', 'bill'].include?(document_type)
        Settlement::ContractorRecord.find_by(id: contractor_id).nip?
      else
        true
      end
    end
  end
end
