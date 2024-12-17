class ReservationMailer < ApplicationMailer
  def reserve(reservation)
    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      from: 'biuro@kw.krakow.pl',
      subject: "Zarezerwowano: #{reservation.items.map(&:display_name).to_sentence}"
    )
  end

  def remind(reservation)
    return true unless reservation

    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      from: 'biuro@kw.krakow.pl',
      subject: "Przypominamy o oddaniu: #{reservation.items.map(&:display_name).to_sentence}"
    )
  end

  def remind_library_item(reservation)
    return true unless reservation

    @user = reservation.user
    @reservation = reservation

    mail(
      to: @user.email,
      from: 'biuro@kw.krakow.pl',
      subject: "Przypominamy o oddaniu: #{reservation.item.title}"
    )
  end
end
