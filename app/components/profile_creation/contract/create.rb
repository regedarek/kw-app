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
      required(:main_address).filled(:string)
      optional(:optional_address).filled(:string)
      required(:phone).filled(:string)
      required(:acomplished_courses).filled(:array).each(:string).value(included_in?: %w[basic_kw basic basic_without_second second second_winter cave cave_kw ski list blank instructors other_club])
      required(:recommended_by).filled(:array).each(:string).value(included_in?: %w[google facebook friends festival poster course])
      required(:sections).filled(:array).each(:string).value(included_in?: %w[snw sww stj gtw kts])
      required(:positions).filled(:array).each(:string).value(included_in?: %w[candidate regular honorable_kw honorable_pza management senior instructor canceled stj released retired])
      required(:photo).filled(:string)
      required(:course_cert).filled(:string)
      required(:plastic).filled(:bool)
      required(:main_discussion_group).filled(:bool)
      required(:terms_of_service).value(:true?)
    end
  end

  rule(profile: :email) do
    key.failure(I18n.t('errors.email.taken')) if Db::Profile.exists?(email: value)
  end
end
