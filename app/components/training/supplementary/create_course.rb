module Training
  module Supplementary
    class CreateCourse
      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.with(record: Training::Supplementary::CourseRecord.new).call(raw_inputs)
        return Failure(form_outputs.messages) unless form_outputs.success?

        repository.create(form_outputs: form_outputs)

        Success(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
