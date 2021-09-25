  module Charity
    class DonationForm < Dry::Validation::Schema
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:cost).filled(:str?)
        required(:action_type).filled(:str?)
        required(:display_name).filled(:str?)
        optional(:user_id).filled
        required(:terms_of_service).filled(eql?: '1')
      end
    end
  end
