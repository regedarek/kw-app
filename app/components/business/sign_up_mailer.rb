module Business
  class SignUpMailer < ApplicationMailer
    append_view_path 'app/components/'
    append_view_path 'app/components/business'
    layout 'business'

    def sign_up(sign_up_id)
      @sign_up = ::Business::SignUpRecord.find(sign_up_id)

      mail(
        to: @sign_up.email,
        from: "SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>",
        bcc: 'SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>',
        subject: "[#{@sign_up.course.name_with_date}] Zapisałeś/aś się na nasz kurs - opłać zadatek!"
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
        from: "SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>",
        bcc: 'SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>',
        subject: "[#{@sign_up.course.name_with_date}] Zadatek został opłacony - wypełnij dane do ubezpieczenia!"
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
        from: "SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>",
        bcc: 'SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>',
        subject: "[#{@sign_up.course.name_with_date}] Witamy na kursie - skontaktuj się z uczestnikami i instruktorem!"
      ).tap do |message|
        message.mailgun_options = {
          "mailable_id" => @sign_up.id,
          "mailable_type" => @sign_up.class.name
        }
      end
    end

    def deleted_sign_up(course, email)
      @course = course
      mail(
        to: email,
        from: "SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>",
        bcc: 'SzkolaAlpinizmu.pl <zapisy@szkolaalpinizmu.pl>',
        subject: "[#{@course.name_with_date}] Twój czas na płatność za zadatek wygasł!"
      )
    end
  end
end
