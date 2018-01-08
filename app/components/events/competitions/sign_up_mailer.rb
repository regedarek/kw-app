module Events
  module Competitions
    class SignUpMailer < ApplicationMailer
      append_view_path 'app/components/'

      def sign_up(sign_up)
        @sign_up = sign_up

        mail(
          to: @sign_up.participant_email_1,
          from: 'kw@kw.krakow.pl',
          subject: 'Zapisałeś się na zawody KW Kraków'
        )
      end
    end
  end
end
