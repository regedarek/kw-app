  module Management
    class CreateProject
      include Dry::Monads::Either::Mixin

      def initialize(form)
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.call(raw_inputs.to_unsafe_h)
        return Left(form_outputs.messages.values) unless form_outputs.success?

        course = Management::ProjectRecord.create(form_outputs.to_h)

        Right(:success)
      end

      private

      attr_reader :form
    end
  end
