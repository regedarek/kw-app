class ReservationMailer < ApplicationMailer
  def reserve(reservation)
    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      from: 'wypozyczalnia.kw.krakow@gmail.com',
      cc: 'wypozyczalnia.kw.krakow@gmail.com',
      subject: "Zarezerwowano: #{reservation.items.map(&:name)}"
    )
  end

  def remind(reservation)
    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      cc: 'wypozyczalnia.kw.krakow@gmail.com',
      from: 'wypozyczalnia.kw.krakow@gmail.com',
      subject: "Przypominamy o oddaniu: #{reservation.items.map(&:name)}"
    )
  end
end
