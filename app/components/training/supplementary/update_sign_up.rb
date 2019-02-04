module Training
  module Supplementary
    class UpdateSignUp
      include Dry::Monads::Either::Mixin

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(id:, raw_inputs:)
        form_outputs = form.call(raw_inputs)
        return Left(form_outputs.messages(locale: I18n.locale)) unless form_outputs.success?

        sign_up = Training::Supplementary::SignUpRecord.find(id)
        sign_up.update(form_outputs.to_h)

        Right(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
