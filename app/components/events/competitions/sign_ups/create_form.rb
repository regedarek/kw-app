require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module
end

module Events
  module Competitions
    module SignUps
      class CreateForm < Dry::Validation::Schema::Form
        configure do
          config.messages = :i18n
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end

        define! do
          required(:single, Types::Form::Bool).filled(:bool?)
          required(:participant_name_2, Types::String).maybe(:str?)
          required(:tshirt_size_2, Types::String).maybe(:str?)
          required(:participant_email_2, Types::String).maybe(:str?)
          required(:participant_birth_year_2, Types::Form::Int).maybe
          required(:competition_package_type_2_id, Types::Form::Int).maybe
          required(:participant_kw_id_2, Types::Form::Int).maybe(:int?, gt?: 1, lt?: 9000)
          required(:participant_gender_2, Types::Form::Int).maybe
          required(:participant_city_2, Types::String)
          required(:participant_team_2, Types::String)
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
              required(:participant_birth_year_2).filled(:int?, lt?: 2003, gt?: 1920)
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
                ::Db::Membership::Fee.exists?(year: Date.today.year, kw_id: participant_kw_id_2)
              else
                true
              end
            else
              true
            end
          end

         required(:participant_name_1, Types::String).filled
         required(:tshirt_size_1, Types::String).filled
         optional(:participant_city_1, Types::String)
         optional(:team_name, Types::String)
         optional(:remarks, Types::String)
         optional(:participant_team_1, Types::String)
         required(:participant_gender_1, Types::Form::Int).filled
         required(:participant_email_1, Types::String).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1, Types::Form::Int).filled(:int?, lt?: 2003, gt?: 1920)
         required(:competition_package_type_1_id, Types::Form::Int).filled
         optional(:participant_kw_id_1, Types::Form::Int).maybe(:int?, gt?: 1, lt?: 9000)
         required(:terms_of_service, Types::Form::Bool).value(:true?)

         validate(active_kw_id_1: [:participant_kw_id_1, :competition_package_type_1_id]) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Db::Membership::Fee.exists?(year: Date.today.year, kw_id: kw_id)
           else
             true
           end
         end
        end
      end
    end
  end
end
