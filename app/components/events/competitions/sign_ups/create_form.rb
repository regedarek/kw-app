require 'dry-validation'

module Events
  module Competitions
    module SignUps
      class CreateForm < Dry::Validation::Schema::Form
        define! do
          required(:participant_name_1).filled(:str?)
          required(:participant_email_1).filled(:str?)
          required(:competition_package_type_1_id).filled(:str?)
          required(:competition_package_type_2_id).filled(:str?)
          required(:terms_of_service).filled(eql?: '1')
        end
      end
    end
  end
end
