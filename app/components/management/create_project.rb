  module Management
    class CreateProject
      include Dry::Monads::Either::Mixin

      def initialize(form)
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.with(record: Management::ProjectRecord.new).call(raw_inputs)
        return Left(form_outputs.messages) unless form_outputs.success?

        course = Management::ProjectRecord.create(form_outputs.to_h)

        Right(:success)
      end

      private

      attr_reader :form
    end
  end
