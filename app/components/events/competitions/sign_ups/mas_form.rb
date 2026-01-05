require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Events
  module Competitions
    module SignUps
      class MasForm < Dry::Validation::Contract
        config.messages.load_paths << 'app/components/events/competitions/sign_ups/errors.yml'
        option :competition_id

        params do
         required(:team_name).filled
         optional(:remarks)
         required(:terms_of_service).filled

         required(:participant_name_1).filled
         optional(:participant_country_1).maybe(:str?)
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:participant_kw_id_1).maybe(:string)
         optional(:participant_team_1)
         required(:participant_phone_1).filled
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:string, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled
         required(:competition_package_type_1_id).filled

         required(:participant_name_2).filled
         optional(:participant_country_2).maybe(:str?)
         optional(:tshirt_size_2).filled
         optional(:participant_city_2)
         optional(:participant_kw_id_2).maybe(:string)
         optional(:participant_team_2)
         required(:participant_phone_2).filled
         required(:participant_gender_2).filled
         required(:participant_email_2).filled(:string, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_2).filled
         required(:competition_package_type_2_id).filled
        end

         rule(:participant_kw_id_1, :competition_package_type_1_id) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end

         rule(:participant_kw_id_2, :competition_package_type_2_id) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end

         rule(:terms_of_service) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end
        end
    end
  end
end
