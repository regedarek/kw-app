require 'dry-validation'

module Events
  module Admin
    module Competitions
      class CreateForm < Dry::Validation::Schema::Form
        define! do
          required(:name).filled(:str?)
        end
      end
    end
  end
end
