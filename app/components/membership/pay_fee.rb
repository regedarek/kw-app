require 'results'

module Membership
  class PayFee
    class << self
      def pay(kw_id:, form:)
        if form.valid?
          last_year_fee = Db::Membership::Fee.find_by(kw_id: kw_id, year: Date.today.last_year.year)
          current_year_fee = Db::Membership::Fee.find_by(kw_id: kw_id, year: Date.today.year)
          base_cost = if last_year_fee.present? && last_year_fee.payment.paid?
                   150
                 elsif current_year_fee.present? && current_year_fee.payment.paid?
                   150
                 else
                   200
                 end
          plastic_cost = form.plastic ? 15 : 0
          cost = base_cost + plastic_cost

          membership_fee = Db::Membership::Fee.create(
            kw_id: kw_id,
            year: form.year,
            cost: cost,
            plastic: form.plastic
          )
          membership_fee.create_payment(dotpay_id: SecureRandom.hex(13))

          return Failure.new(:wrap_payment) unless membership_fee.payment.present?

          Payments::CreatePayment.new(payment: membership_fee.payment).create

          Success.new(payment: membership_fee.payment)
        else
          return Failure.new(:invalid, form: form)
        end
      end
    end
  end
end
