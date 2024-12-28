require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Events
  module Competitions
    module SignUps
      class CreateForm < Dry::Validation::Schema
        configure do
          config.messages = :i18n
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end

        define! do
          required(:single).filled(:bool?)
          required(:participant_name_2).maybe(:str?)
          required(:tshirt_size_2).maybe(:str?)
          required(:participant_email_2).maybe(:str?)
          required(:participant_birth_year_2).maybe
          required(:competition_package_type_2_id).maybe
          required(:participant_kw_id_2).maybe(:int?, gt?: 1, lt?: 9000)
          required(:participant_gender_2).maybe
          required(:participant_city_2)
          required(:participant_team_2)
          rule(participant_gender_2: [:single, :participant_gender_2]) do |single, participant_gender_2|
            single.false?.then(participant_gender_2.filled?)
          end
          rule(participant_name_2: [:single, :participant_name_2]) do |single, participant_name_2|
            single.false?.then(participant_name_2.filled?)
          end
          rule(tshirt_size_2: [:single, :tshirt_size_2]) do |single, tshirt_size_2|
            single.false?.then(tshirt_size_2.filled?)
          end
          rule(participant_email_2: [:single, :participant_name_2]) do |single, participant_email_2|
            single.false?.then(
              required(:participant_email_2).filled(format?: /.@.+[.][a-z]{2,}/i)
            )
          end
          rule(participant_birth_year_2: [:single, :participant_birth_year_2]) do |single, participant_birth_year_2|
            single.false?.then(
              required(:participant_birth_year_2).filled(:int?, gt?: 1920)
            )
          end
          rule(competition_package_type_2_id: [:single, :competition_package_type_2_id]) do |single, competition_package_type_2_id|
            single.false?.then(
              required(:competition_package_type_2_id).filled(:int?)
            )
          end

          validate(active_kw_id_2: [:single, :participant_kw_id_2, :competition_package_type_2_id]) do |single, participant_kw_id_2, competition_package_type_2_id|
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

         required(:participant_name_1).filled
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:team_name)
         optional(:teammate_id)
         optional(:remarks)
         optional(:participant_team_1)
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled(:int?, gt?: 1920)
         required(:competition_package_type_1_id).filled
         optional(:participant_kw_id_1).maybe
         required(:terms_of_service).value(:true?)

         validate(active_kw_id_1: [:participant_kw_id_1, :competition_package_type_1_id]) do |kw_id, package_id|
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
end
