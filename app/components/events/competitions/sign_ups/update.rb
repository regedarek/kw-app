module Events
  module Competitions
    module SignUps
      class Update
        include Dry::Monads::Either::Mixin

        def initialize(competitions_repository, create_sign_up_form)
          @competitions_repository = competitions_repository
          @create_sign_up_form = create_sign_up_form
        end

        def call(sign_up_record_id:, raw_inputs:)
          form_outputs = create_sign_up_form.call(raw_inputs.to_h)
          return Left(form_outputs.messages(locale: I18n.locale)) unless form_outputs.success?

          sign_up = competitions_repository.update_sign_up(
            sign_up_record_id: sign_up_record_id, form_outputs: form_outputs
          )
          Right(:success)
        end

        private

        attr_reader :competitions_repository, :create_sign_up_form
      end
    end
  end
end
