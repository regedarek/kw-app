class ProfileCreation::Contract::Create < Dry::Validation::Contract
  config.messages.backend = :i18n

  params do
    required(:profile).hash do
      required(:locale).filled(:string, included_in?: %w[pl en])
      required(:first_name).filled(:string)
      required(:last_name).filled(:string)
    end
  end
end
