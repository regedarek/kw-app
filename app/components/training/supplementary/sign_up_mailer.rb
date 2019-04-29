module Training
  module Supplementary
    class SignUpMailer < ApplicationMailer
      append_view_path 'app/components/'

      def sign_up(sign_up_id)
        @sign_up = ::Training::Supplementary::SignUpRecord.find(sign_up_id)
        organizer = ::Db::User.find(@sign_up.course.organizator_id)

        mail(
          to: @sign_up.email,
          from: organizer&.email,
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
