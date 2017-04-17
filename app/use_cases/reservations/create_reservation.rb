require 'results'

module Reservations
  class CreateReservation
    class << self
      def create(user:, form:)
        return Failure.new(:form_invalid, form: form) unless form.valid?
        if (items_reserved_in_period(form.start_date) & form.item_ids).any?
          return Failure.new(:item_already_reserved, form: form)
        end

        reservation = Db::Reservation
          .where(start_date: form.start_date)
          .not_prepaid
          .not_cash
          .first_or_initialize(form.attributes)

        if reservation.payment.present? && reservation.payment.paid?
          reservation = Db::Reservation.new(form.attributes)
        end

        reservation.user = user
        items_to_add = (reservation.items + form.items).uniq
        reservation.items = items_to_add
        reservation.save
        reservation.create_payment(dotpay_id: SecureRandom.hex(13))

        Success.new
      end

      def items_reserved_in_period(start_date)
        Db::Reservation.where(start_date: start_date).map(&:item_ids).flatten.uniq
      end
    end
  end
end
