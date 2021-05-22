require 'i18n'
require 'dry-validation'
require 'nip_pesel_regon'

module Settlement
  ContractorForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }

    required(:name).filled
    optional(:nip).maybe
    optional(:logo).maybe
    optional(:phone).maybe
    optional(:email).maybe
    optional(:www).maybe
    optional(:contact_name).maybe
    required(:reason_type).filled
    required(:profession_type).filled
    optional(:description).maybe
    validate(unique_nip: :nip) do |nip|
      if nip.nil? || nip.empty?
        true
      else
        if NipPeselRegon::Validator::Nip.new(nip).valid?
          !Settlement::ContractorRecord.exists?(nip: nip)
        else
          false
        end
      end
    end
  end
end
