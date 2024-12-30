  module Charity
    class DonationForm < Dry::Validation::Contract
      config.messages.load_paths << 'app/components/training/errors.yml'

      params do
        required(:cost).filled(:string)
        required(:action_type).filled(:string)
        required(:display_name).filled(:string)
        optional(:user_id).filled
        required(:terms_of_service).filled(eql?: '1')
      end
    end
  end
