module Settlement
  class ContractorForm < Dry::Validation::Contract
    config.messages.load_paths << 'app/components/settlement/errors.yml'

    params do
      required(:name).filled
      optional(:nip)
      optional(:logo)
      optional(:phone)
      optional(:email)
      optional(:www)
      optional(:contact_name)
      required(:reason_type).filled
      required(:profession_type).filled
      optional(:description)
    end

    rule(:nip) do |nip|
      if nip.nil? || nip.empty?
        true
      else
        !Settlement::ContractorRecord.exists?(nip: nip)
      end
    end
  end
end
