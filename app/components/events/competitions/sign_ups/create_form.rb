module Events
  module Competitions
    module SignUps
      class CreateForm < Dry::Validation::Contract
          config.messages.load_paths << 'app/components/events/competitions/sign_ups/errors.yml'

          params do
            required(:single).filled(:bool)
            required(:participant_name_2).maybe(:string)
            required(:tshirt_size_2).maybe(:string)
            required(:participant_email_2).maybe(:string)
            required(:participant_birth_year_2)
            required(:competition_package_type_2_id)
            required(:participant_kw_id_2).maybe(:integer, gt?: 1, lt?: 9000)
            required(:participant_gender_2)
            required(:participant_city_2)
            required(:participant_team_2)
         required(:participant_name_1).filled(:string)
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:team_name)
         optional(:teammate_id)
         optional(:remarks)
         optional(:participant_team_1)
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:string, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled(:integer, gt?: 1920)
         required(:competition_package_type_1_id).filled
         optional(:participant_kw_id_1)
         required(:terms_of_service).value(:true?)
          end
          rule(:single, :participant_gender_2) do |single, participant_gender_2|
            single.false?.then(participant_gender_2.filled?)
          end
          rule(:single, :participant_name_2) do |single, participant_name_2|
            single.false?.then(participant_name_2.filled?)
          end
          rule(:single, :tshirt_size_2) do |single, tshirt_size_2|
            single.false?.then(tshirt_size_2.filled?)
          end
          rule(:single, :participant_name_2) do |single, participant_email_2|
            single.false?.then(
              required(:participant_email_2).filled(format?: /.@.+[.][a-z]{2,}/i)
            )
          end
          rule(:single, :participant_birth_year_2) do |single, participant_birth_year_2|
            single.false?.then(
              required(:participant_birth_year_2).filled(:int?, gt?: 1920)
            )
          end
          rule(:single, :competition_package_type_2_id) do |single, competition_package_type_2_id|
            single.false?.then(
              required(:competition_package_type_2_id).filled(:int?)
            )
          end

          rule(:single, :participant_kw_id_2, :competition_package_type_2_id) do |single, participant_kw_id_2, competition_package_type_2_id|
            if !single && competition_package_type_2_id.present?
              if Events::Db::CompetitionPackageTypeRecord.find(competition_package_type_2_id).membership?
                ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: participant_kw_id_2)).active?
              else
                true
              end
            else
              true
            end
          end



         rule(:participant_kw_id_1, :competition_package_type_1_id) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end
        end
    end
  end
end
