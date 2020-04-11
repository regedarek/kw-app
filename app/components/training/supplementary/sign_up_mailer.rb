module Training
  module Supplementary
    class SignUpMailer < ApplicationMailer
      append_view_path 'app/components/'

      def prepaid_email(sign_up_id)
        @sign_up = ::Training::Supplementary::SignUpRecord.find(sign_up_id)
        organizer = ::Db::User.find(@sign_up.course.organizator_id)

        mail(
          to: ['wydarzenia@kw.krakow.pl', @sign_up.email, organizer.email],
          from: 'wydarzenia@kw.krakow.pl',
          subject: "Opłaciłes zapis na wydarzenie KW Kraków: #{@sign_up.course.name}!"
        ).tap do |message|
          message.mailgun_options = {
            "mailable_id" => "#{@sign_up.id}-prepaid_email",
            "mailable_type" => @sign_up.class.name
          }
        end
      end

      def sign_up(sign_up_id)
        @sign_up = ::Training::Supplementary::SignUpRecord.find(sign_up_id)
        organizer = ::Db::User.find(@sign_up.course.organizator_id)

        mail(
          to: ['wydarzenia@kw.krakow.pl', @sign_up.email, organizer.email],
          from: 'wydarzenia@kw.krakow.pl',
          subject: "Zapisałeś się na wydarzenie KW Kraków: #{@sign_up.course.name}!"
        ).tap do |message|
          message.mailgun_options = {
            "mailable_id" => @sign_up.id,
            "mailable_type" => @sign_up.class.name
          }
        end
      end
    end
  end
end
