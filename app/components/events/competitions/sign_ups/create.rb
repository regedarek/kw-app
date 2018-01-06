module Events
  module Competitions
    module SignUps
      class Create
        include Dry::Monads::Either::Mixin

        def initialize(competitions_repository, create_sign_up_form)
          @competitions_repository = competitions_repository
          @create_sign_up_form = create_sign_up_form
        end

        def call(competition_id:, raw_inputs:)
          form_outputs = create_sign_up_form.call(raw_inputs)
          return Left(form_outputs.messages(full: true)) unless form_outputs.success?

          competitions_repository.create_sign_up(
            competition_id: competition_id, form_outputs: form_outputs
          )

          Right(:success)
        end

        private

        attr_reader :competitions_repository, :create_sign_up_form
      end
    end
  end
end
