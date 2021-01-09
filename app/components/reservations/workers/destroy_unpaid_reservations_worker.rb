module Reservations
  module Workers
    class DestroyUnpaidReservationsWorker
      include Sidekiq::Worker

      def perform(**)
        not_prepaid = Db::Reservation.where('reservations.created_at < ?', 2.day.ago)
                                    .not_prepaid
        prepaid_by_cash = Db::Reservation.where('reservations.created_at < ?', 2.day.ago)
                                        .cash_prepaid
        to_destroy = not_prepaid - prepaid_by_cash
        to_destroy.map(&:destroy)
      end
    end
  end
end
