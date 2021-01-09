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
          form_outputs = create_sign_up_form.with(competition_id: competition_id).call(raw_inputs.to_unsafe_h)
          return Left(form_outputs.messages(locale: I18n.locale)) unless form_outputs.success?

          sign_up = competitions_repository.create_sign_up(
            competition_id: competition_id, form_outputs: form_outputs
          )
          if sign_up.competition_record.close_payment.present?
            sign_up.update(expired_at: sign_up.competition_record.close_payment)
          end
          if sign_up.competition_record.accept_first?
            Events::Competitions::SignUpMailer.sign_up_accept_first(sign_up.id).deliver_later
          else
            Events::Competitions::SignUpMailer.sign_up(sign_up.id).deliver_later
            sign_up.update(sent_at: Time.zone.now)
          end

          Right(:success)
        end

        private

        attr_reader :competitions_repository, :create_sign_up_form
      end
    end
  end
end
