module Business
  class SignUpMailer < ApplicationMailer
    append_view_path 'app/components/'

    def sign_up(sign_up_id)
      @sign_up = ::Business::SignUpRecord.find(sign_up_id)

      mail(
        to: @sign_up.email,
        from: 'zapisy@szkolaalpinizmu.pl',
        cc: 'zapisy@szkolaalpinizmu.pl',
        subject: "Zapisałeś się na #{@sign_up.course.name}!"
      ).tap do |message|
        message.mailgun_options = {
          "mailable_id" => @sign_up.id,
          "mailable_type" => @sign_up.class.name
        }
      end
    end

    def list(sign_up_id)
      @sign_up = ::Business::SignUpRecord.find(sign_up_id)

      mail(
        to: @sign_up.email,
        from: 'zapisy@szkolaalpinizmu.pl',
        cc: 'zapisy@szkolaalpinizmu.pl',
        subject: "Zgłosiłeś zapotrzebowanie #{@sign_up.course.name}!"
      ).tap do |message|
        message.mailgun_options = {
          "mailable_id" => @sign_up.id,
          "mailable_type" => @sign_up.class.name
        }
      end
    end

    def sign_up_second(sign_up_id)
      @sign_up = ::Business::SignUpRecord.find(sign_up_id)

      mail(
        to: @sign_up.email,
        from: 'zapisy@szkolaalpinizmu.pl',
        cc: 'zapisy@szkolaalpinizmu.pl',
        subject: "Zapisałeś się na #{@sign_up.course.name}: wpłać resztę!"
      ).tap do |message|
        message.mailgun_options = {
          "mailable_id" => @sign_up.id,
          "mailable_type" => @sign_up.class.name
        }
      end
    end
  end
end
