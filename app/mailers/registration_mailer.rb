class RegistrationMailer < ApplicationMailer
  def welcome(user, password)
    @user = user
    @password = password

    I18n.with_locale(I18n.locale) do
      mail(
        to: @user.email,
        from: 'kw@kw.krakow.pl',
        subject: t('.subject')
      )
    end
  end
end
