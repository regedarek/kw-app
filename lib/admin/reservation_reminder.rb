module Admin
  class ReservationReminder
    def self.send_reminders
      Db::Reservation.expire_tomorrow.each do |reservation|
        ReservationMailer.remind(reservation).deliver
      end
    end
  end
end
