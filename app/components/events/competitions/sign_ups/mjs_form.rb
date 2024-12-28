require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Events
  module Competitions
    module SignUps
      class MjsForm < Dry::Validation::Schema
        configure do
          config.messages = :i18n
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end
        configure { option :competition_id }

        define! do
         required(:participant_first_name_1).filled
         required(:participant_name_1).filled
         required(:participant_country_1).filled
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:team_name)
         optional(:teammate_id)
         optional(:remarks)
         optional(:license_number)
         optional(:participant_kw_id_1).maybe(:str?)
         optional(:participant_license_id_1)
         optional(:participant_team_1)
         required(:participant_phone_1).filled
         required(:participant_phone_2).filled
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled
         required(:competition_package_type_1_id).filled
         optional(:rescuer)
         optional(:friday_night)
         optional(:saturday_night)
         required(:terms_of_service).filled
         required(:medical_rules).filled
         validate(active_kw_id_1: [:participant_kw_id_1, :competition_package_type_1_id]) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end

         validate(correct_junior_category_1: [:participant_birth_year_1, :competition_package_type_1_id]) do |year, package_id|
           package = Events::Db::CompetitionPackageTypeRecord.find(package_id)

           if package.junior_year.present? && package.junior_year > year.to_i
            false
           else
             true
           end
         end

         validate(terms_of_service_true: [:terms_of_service]) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end

         validate(medical_rules_true: [:medical_rules]) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end
        end
      end
    end
  end
end
