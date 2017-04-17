require 'orders'
require 'results'

module Membership
  class PayFee
    class << self
      def pay(kw_id:, form:)
        if form.valid?
          last_year_fee = Db::MembershipFee.find_by(kw_id: kw_id, year: Date.today.last_year.year)
          current_year_fee = Db::MembershipFee.find_by(kw_id: kw_id, year: Date.today.year)
          cost = if last_year_fee.present? && last_year_fee.payment.prepaid?
                   100
                 elsif current_year_fee.present? && current_year_fee.payment.prepaid?
                   100
                 else
                   150
                 end
          membership_fee = Db::MembershipFee.create(
            kw_id: kw_id,
            year: form.year,
            cost: cost
          )

          return Failure.new(:wrap_payment) if membership_fee.payment.present?

          Payments::CreatePayment.new(payment: membership_fee.payment).create

          Success.new(payment: membership_fee.payment)
        else
          return Failure.new(:invalid, form: form)
        end
      end
    end
  end
end
