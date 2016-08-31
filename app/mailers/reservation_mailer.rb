class ReservationMailer < ApplicationMailer
  def reserve(reservation)
    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      cc: 'wypozycz-kw-krakow@googlegroups.com',
      subject: "Zarezerwowano: #{reservation.items.map(&:name)}"
    )
  end

  def remind(reservation)
    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      cc: 'wypozycz-kw-krakow@googlegroups.com',
      subject: "Przypominamy o oddaniu: #{reservation.items.map(&:name)}"
    )
  end
end
