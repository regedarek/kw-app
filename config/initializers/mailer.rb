class PostmarkMailObserver
  def self.delivered_email(mail)
    if mail.mailgun_options
      mailable_id = mail.mailgun_options.fetch("mailable_id", nil)
      mailable_type = mail.mailgun_options.fetch("mailable_type", nil)

      if mailable_id && mailable_type
        EmailCenter::EmailRecord.create(
          message_id: mail.message_id,
          mailable_id: mailable_id,
          mailable_type: mailable_type
        )
      end
    end

    puts ">>> Postmark Message-ID: #{mail.message_id}"
  end
end
ActionMailer::Base.register_observer(PostmarkMailObserver)
