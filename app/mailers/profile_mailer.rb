class ProfileMailer < ApplicationMailer
  def apply(profile)
    @profile = profile

    I18n.with_locale(I18n.locale) do
      mail(
        to: @profile.email,
        cc: 'kw@kw.krakow.pl',
        from: 'kw@kw.krakow.pl',
        subject: "Potwierdzenie zgłoszenia do KW Kraków od #{@profile.first_name} #{@profile.last_name}"
      )
    end
  end
end
