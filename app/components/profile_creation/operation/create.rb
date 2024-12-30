class ProfileCreation::Operation::Create
  include Dry::Monads[:maybe, :try, :result, :do]

  def call(params: {})
    profile_params = yield validate!(params: params)
    profile        = yield create_profile!(profile_params: profile_params)

    Success(profile)
  end

  private

  def validate!(params:)
    ProfileCreation::Contract::Create.new
    .call(params)
      .to_monad
      .fmap { |params| params.to_h }
      .or   { |schema| Failure([ :invalid, schema ]) }
  end

  def create_profile!(profile_params:)
    Try do
      Db::Profile.create!(profile_params)
    end.to_result
  end
end
