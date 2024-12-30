module Events
  module Admin
    module Competitions
      class CreateForm < Dry::Validation::Contract
        params do
          required(:name).filled(:string)
          required(:email_text).filled(:string)
          required(:edition_sym).filled(:string)
        end
      end
    end
  end
end
