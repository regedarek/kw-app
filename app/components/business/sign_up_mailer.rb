module Business
  class SignUpMailer < ApplicationMailer
    append_view_path 'app/components/'

    def sign_up(sign_up_id)
      @sign_up = ::Business::SignUpRecord.find(sign_up_id)

      mail(
        to: @sign_up.email,
        from: 'zapisy@szkolaalpinizmu.pl',
        cc: 'zapisy@szkolaalpinizmu.pl',
        subject: "[#{@sign_up.course.name_with_date}] - Zapisano na kurs #{@sign_up.name}"
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
        subject: "[#{@sign_up.course.name_with_date}] - Zapisano na kurs #{@sign_up.name}"
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
        subject: "[#{@sign_up.course.name_with_date}] - Zapisano na kurs #{@sign_up.name}"
      ).tap do |message|
        message.mailgun_options = {
          "mailable_id" => @sign_up.id,
          "mailable_type" => @sign_up.class.name
        }
      end
    end
  end
end
