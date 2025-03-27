require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module
end

module Events
  module Competitions
    module SignUps
      class MasForm < Dry::Validation::Schema
        configure do
          config.messages = :i18n
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end
        configure { option :competition_id }

        define! do
         required(:team_name).filled
         optional(:remarks)
         required(:terms_of_service).filled

         required(:participant_name_1).filled
         optional(:participant_country_1).maybe(:str?)
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:participant_kw_id_1).maybe(:str?)
         optional(:participant_team_1)
         required(:participant_phone_1).filled
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled
         required(:competition_package_type_1_id).filled

         required(:participant_name_2).filled
         optional(:participant_country_2).maybe(:str?)
         optional(:tshirt_size_2).filled
         optional(:participant_city_2)
         optional(:participant_kw_id_2).maybe(:str?)
         optional(:participant_team_2)
         required(:participant_phone_2).filled
         required(:participant_gender_2).filled
         required(:participant_email_2).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_2).filled
         required(:competition_package_type_2_id).filled

         validate(active_kw_id_1: [:participant_kw_id_1, :competition_package_type_1_id]) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end

         validate(active_kw_id_2: [:participant_kw_id_2, :competition_package_type_2_id]) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end

         validate(terms_of_service_true: [:terms_of_service]) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end
        end
      end
    end
  end
end
