module Training
  module Questionare
    class SnwProfileRepository
      def create(form_outputs)
        Training::Questionare::SnwProfileRecord.create!(form_outputs)
      end
    end
  end
end
