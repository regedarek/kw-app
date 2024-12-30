module Events
  module Competitions
    module SignUps
      class DefaultForm < Dry::Validation::Contract
        config.messages.load_paths << 'app/components/events/competitions/sign_ups/errors.yml'

        params do
         required(:participant_name_1).filled
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:team_name)
         optional(:teammate_id)
         optional(:remarks)
         optional(:participant_team_1)
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:string, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled
         required(:competition_package_type_1_id).filled
         optional(:participant_kw_id_1)
         required(:terms_of_service).filled
         optional(:participant_country_1)
         optional(:participant_license_id_1)
        end

         rule(:terms_of_service) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end

         rule(:participant_country_1, :participant_license_id_1, :competition_package_type_1_id) do |participant_country_1, participant_license_id_1, competition_package_type_1_id|
           if participant_country_1 == 'pl' && Events::Db::CompetitionPackageTypeRecord.find(competition_package_type_1_id).name == 'Puchar Polski'
             if participant_license_id_1 == '0'
               false
             else
              participant_license_id_1.present?
             end
           else
             true
           end
         end
        end
      end
  end
end
