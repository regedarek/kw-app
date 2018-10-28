module Training
  module Supplementary
    class CreatePackage
      include Dry::Monads::Either::Mixin

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.call(raw_inputs)
        return Left(form_outputs.messages(full: true)) unless form_outputs.success?

        repository.create_package(form_outputs: form_outputs)
        Right(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
