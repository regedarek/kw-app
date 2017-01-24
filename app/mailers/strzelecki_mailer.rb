class StrzeleckiMailer < ApplicationMailer
  def sign_up(sign_up)
    @sign_up = sign_up

    mail(
      to: @sign_up.email,
      cc: 'dariusz.finster@gmail.com',
      subject: "Zapisano do Strzeleckiego 2017"
    )
  end
end
