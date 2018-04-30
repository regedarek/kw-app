module Events
  module Competitions
    class SignUpMailer < ApplicationMailer
      append_view_path 'app/components/'

      def sign_up(sign_up_id)
        @sign_up = ::Events::Competitions::Repository.new.find_sign_up(sign_up_id)

        mail(
          to: @sign_up.participant_email_1,
          cc: [@sign_up.competition_record.organizer_email, @sign_up.participant_email_2].compact,
          from: @sign_up.competition_record.organizer_email,
          subject: "Zapisałeś się na zawody KW Kraków: #{@sign_up.competition_record.name}!"
        )
      end
    end
  end
end
