module Events
  module Competitions
    class SignUpMailer < ApplicationMailer
      append_view_path 'app/components/'

      def sign_up(sign_up_id)
        @sign_up = ::Events::Competitions::Repository.new.find_sign_up(sign_up_id)

        mail(
          to: @sign_up.participant_email_1,
          cc: ['strzelecki@kw.krakow.pl', @sign_up.participant_email_2].compact,
          from: 'strzelecki@kw.krakow.pl',
          subject: "Zapisałeś się na zawody KW Kraków: #{@sign_up.competition_record.name}!"
        )
      end
    end
  end
end
