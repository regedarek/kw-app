require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module
end

module Events
  module Competitions
    module SignUps
      class SignUpSingleForm < Dry::Validation::Schema
        configure do
          config.messages = :i18n
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end

        define! do
         required(:participant_name_1).filled
         optional(:tshirt_size_1).filled
         optional(:participant_city_1)
         optional(:team_name)
         optional(:teammate_id)
         optional(:remarks)
         optional(:participant_team_1)
         required(:participant_gender_1).filled
         required(:participant_email_1).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1).filled
         required(:competition_package_type_1_id).filled
         optional(:participant_kw_id_1)
         required(:terms_of_service).filled

         validate(terms_of_service_true: [:terms_of_service]) do |terms|
           ActiveRecord::Type::Boolean.new.cast(terms)
         end
        end
      end
    end
  end
end
