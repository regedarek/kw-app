  module Management
    class CreateProject

      def initialize(form)
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.call(raw_inputs.to_unsafe_h)
        return Failure(form_outputs.messages.values) unless form_outputs.success?

        Management::ProjectRecord.create(form_outputs.to_h)

        Success(:success)
      end

      private

      attr_reader :form
    end
  end
