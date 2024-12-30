require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Events
  module Competitions
    module SignUps
      class MjsForm < Dry::Validation::Contract
        config.messages.load_paths << 'app/components/events/competitions/sign_ups/errors.yml'
        option :competition_id

        params do
         required(:participant_first_name_1).filled
         required(:participant_name_1).filled
         required(:participant_country_1).filled
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:team_name)
         optional(:teammate_id)
         optional(:remarks)
         optional(:license_number)
         optional(:participant_kw_id_1).maybe(:string)
         optional(:participant_license_id_1)
         optional(:participant_team_1)
         required(:participant_phone_1).filled
         required(:participant_phone_2).filled
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:string, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled
         required(:competition_package_type_1_id).filled
         optional(:rescuer)
         optional(:friday_night)
         optional(:saturday_night)
         required(:terms_of_service).filled
         required(:medical_rules).filled
        end
         rule(:participant_kw_id_1, :competition_package_type_1_id) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end

         rule(:participant_birth_year_1, :competition_package_type_1_id) do |year, package_id|
           package = Events::Db::CompetitionPackageTypeRecord.find(package_id)

           if package.junior_year.present? && package.junior_year > year.to_i
            false
           else
             true
           end
         end

         rule(:terms_of_service) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end

         rule(:medical_rules) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end
        end
      end
  end
end
