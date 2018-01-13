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
          form_outputs = create_sign_up_form.call(raw_inputs.to_h)
          return Left(form_outputs.messages(locale: :pl)) unless form_outputs.success?

          sign_up = competitions_repository.create_sign_up(
            competition_id: competition_id, form_outputs: form_outputs
          )
          if Rails.env.development?
            Events::Competitions::SignUpMailer
              .sign_up(sign_up.id).deliver_now
          else
            Events::Competitions::SignUpMailer
              .sign_up(sign_up.id).deliver_later
          end

          Right(:success)
        end

        private

        attr_reader :competitions_repository, :create_sign_up_form
      end
    end
  end
end
