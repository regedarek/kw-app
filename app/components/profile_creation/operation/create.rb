class ProfileCreation::Operation::Create
  include Dry::Monads[:maybe, :try, :result, :do]

  def call(params: {})
    profile        = Db::Profile.new
    profile_params = yield validate!(profile: profile, params: params)
    profile        = yield persist_profile!(profile: profile, profile_params: profile_params)

    Success(profile)
  end

  private

  def validate!(profile:, params:)
    ProfileCreation::Contract::Create.new
    .call(params)
      .to_monad
      .fmap { |params| params.to_h[:profile].except(:terms_of_service) }
      .or do |contract|
        profile = Db::Profile.new(contract.to_h[:profile])
        contract.errors(locale: profile.locale).each do |error|
          profile.errors.add(error.path.excluding(:profile).sole, error.text)
        end
        Failure([ :invalid, profile ])
      end
  end

  def persist_profile!(profile:, profile_params:)
    profile.assign_attributes(profile_params)
    profile.save

    Success(profile)
  end
end
