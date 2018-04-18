module Training
  module Questionare
    class SnwProfileService
      include Dry::Monads::Either::Mixin

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def create(raw_inputs)
        form_outputs = @form.call(raw_inputs)
        return Left(form_outputs.messages(full: true)) unless form_outputs.success?
        repository.create(form_outputs)
        Right(:success)
      end
    end
  end
end
