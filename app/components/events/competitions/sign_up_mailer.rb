module Events
  module Competitions
    class SignUpMailer < ApplicationMailer
      append_view_path 'app/components/'

      def sign_up(repository, sign_up_id)
        @sign_up = repository.find_sign_up(sign_up_id)

        mail(
          to: @sign_up.participant_email_1,
          from: 'kw@kw.krakow.pl',
          subject: "Zapisałeś się na zawody KW Kraków: #{@sign_up.competition.name}"
        )
      end
    end
  end
end
