class MasMailer < ApplicationMailer
  def sign_up(sign_up)
    @sign_up = sign_up

    I18n.with_locale(I18n.locale) do
      mail(
        to: @sign_up.email_1,
        from: 'mas@kw.krakow.pl',
        subject: t('.subject', id: @sign_up.id)
      )
    end
  end
end
