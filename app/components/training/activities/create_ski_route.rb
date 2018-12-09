module Training
  module Activities
    class CreateSkiRoute
      include Dry::Monads::Either::Mixin

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(raw_inputs:, user_id:)
        form_outputs = form.call(raw_inputs)
        return Left(form_outputs.messages(full: true)) unless form_outputs.success?

        repository.create(form_outputs: form_outputs, user_id: user_id)
        Right(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
