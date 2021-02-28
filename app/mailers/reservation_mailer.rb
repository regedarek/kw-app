class ReservationMailer < ApplicationMailer
  def reserve(reservation)
    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      from: 'kw@kw.krakow.pl',
      subject: "Zarezerwowano: #{reservation.items.map(&:display_name).to_sentence}"
    )
  end

  def remind(reservation)
    return true unless reservation

    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      from: 'kw@kw.krakow.pl',
      subject: "Przypominamy o oddaniu: #{reservation.items.map(&:display_name).to_sentence}"
    )
  end
end
