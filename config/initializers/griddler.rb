Griddler.configure do |config|
  config.email_service = :sendgrid

  config.processor_class = ::EmailCenter::Mailman
  config.reply_delimiter = '-- ODPOWIEDZ E-MAILOWO POWYŻEJ TEJ LINI --'
  config.processor_method = :handle_it
end
