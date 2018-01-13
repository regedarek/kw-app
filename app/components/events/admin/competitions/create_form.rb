require 'dry-validation'

module Events
  module Admin
    module Competitions
      class CreateForm < Dry::Validation::Schema::Form
        define! do
          required(:name).filled(:str?)
          required(:email_text).filled(:str?)
          required(:edition_sym).filled(:str?)
        end
      end
    end
  end
end
