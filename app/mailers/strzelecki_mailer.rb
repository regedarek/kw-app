class StrzeleckiMailer < ApplicationMailer
  def sign_up(sign_up)
    @sign_up = sign_up

    mail(
      to: @sign_up.email_1,
      from: 'dariusz.finster@gmail.com',
      cc: 'dariusz.finster@gmail.com',
      subject: "Strzelecki 2017 - zapisy"
    )
  end
end
