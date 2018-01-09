module Admin
  class ReservationReminder
    def self.send_reminders
      Db::Reservation.expire_tomorrow.each do |reservation|
        ReservationMailer.remind(reservation).deliver_later
      end
      Net::HTTP.get(URI('https://hchk.io/5e85e1e8-1695-454c-a8cf-f50b8c620417'))
    end
  end
end
