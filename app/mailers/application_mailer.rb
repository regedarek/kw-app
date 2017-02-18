class ApplicationMailer < ActionMailer::Base
  default from: 'Klub Wysokogórski Kraków <postmaster@kw.krakow.pl>'
  append_view_path Rails.root.join('app', 'views', 'mailers')

  layout 'mailer'
end
