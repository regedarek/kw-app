module Training
  module Questionare
    class SnwProfileForm < Dry::Validation::Schema
      define! do
        required(:question_1).filled(:str?)
        required(:question_2).maybe
      end
    end
  end
end
