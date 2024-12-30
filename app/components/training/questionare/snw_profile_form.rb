module Training
  module Questionare
    class SnwProfileForm < Dry::Validation::Contract
      params do
        required(:question_1).filled(:string)
        required(:question_2)
      end
    end
  end
end
