class StrzeleckiMailer < ApplicationMailer
  def sign_up(sign_up)
    @sign_up = sign_up

    mail(
      to: @sign_up.email_1,
      from: 'strzelecki@kw.krakow.pl',
      subject: "Memoriał Jana Strzeleckiego 2017 - Rejestracja na zawody: #{@sign_up.id}"
    )
  end
end
