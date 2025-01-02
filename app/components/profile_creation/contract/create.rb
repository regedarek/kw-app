class ProfileCreation::Contract::Create < Dry::Validation::Contract
  config.messages.backend = :i18n

  params do
    required(:profile).hash do
      optional(:first_name).filled(:string)
      optional(:last_name).filled(:string)
    end
  end
end
