require 'i18n'
require 'dry-validation'

module Settlement
  ContractorForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/settlement/errors.yml' }
    configure { config.messages = :i18n }
    configure do
      def self.messages
        super.merge(
          en: { errors: { unique_nip: 'nip już istnieje' } }
        )
      end
    end

    required(:name).filled
    optional(:nip).maybe
    optional(:logo).maybe
    optional(:phone).maybe
    optional(:email).maybe
    optional(:www).maybe
    optional(:contact_name).maybe
    required(:reason_type).filled
    optional(:description).maybe

    validate(unique_nip: :nip) do |nip|
      true if nip.nil?

      !Settlement::ContractorRecord.exists?(nip: nip)
    end
  end
end
