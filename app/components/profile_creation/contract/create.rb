class ProfileCreation::Contract::Create < Dry::Validation::Contract
  config.messages.backend = :i18n

  params do
    required(:profile).hash do
      required(:locale).filled(:string, included_in?: %w[pl en])
      required(:first_name).filled(:string)
      required(:last_name).filled(:string)
      required(:email).filled(:string, format?: URI::MailTo::EMAIL_REGEXP)
      required(:gender).filled(:string, included_in?: %w[male female])
      required(:birth_place).filled(:string)
      required(:birth_date).filled(:date)
      required(:city).filled(:string)
      required(:postal_code).filled(:string)
      required(:phone).filled(:string)
      required(:acomplished_courses).filled(:array).each(:string)
      required(:optional_address).filled(:string)
      optional(:recommended_by)
      required(:sections).filled(:array).each(:string)
      required(:course_cert)
      required(:photo)
      required(:main_discussion_group).filled(:bool)
      required(:terms_of_service).value(:bool)
    end
  end

  rule(profile: :email) do
    key.failure(I18n.t('errors.taken')) if Db::Profile.exists?(email: value)
  end
end
