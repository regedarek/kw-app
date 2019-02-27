module Training
  module Supplementary
    class CreateCourse
      include Dry::Monads::Either::Mixin

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.with(record: Training::Supplementary::CourseRecord.new).call(raw_inputs)
        return Left(form_outputs.messages(full: true)) unless form_outputs.success?

        course = repository.create(form_outputs: form_outputs)
        course.update(packages: true) if course.package_types.any?

        Right(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
