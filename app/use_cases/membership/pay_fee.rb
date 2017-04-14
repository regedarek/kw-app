require 'orders'
require 'results'

module Membership
  class PayFee
    class << self
      def pay(kw_id:, form:)
        if form.valid?
          last_year_fee = Db::MembershipFee.find_by(kw_id: kw_id, year: Date.today.last_year.year)
          current_year_fee = Db::MembershipFee.find_by(kw_id: kw_id, year: Date.today.year)
          cost = if last_year_fee.present? && last_year_fee.order.present? && last_year_fee.order.prepaid?
                   100
                 elsif current_year_fee.present? && current_year_fee.order.present? && current_year_fee.order.prepaid?
                   100
                 else
                   150
                 end
          membership_fee = Db::MembershipFee.create(
            kw_id: kw_id,
            year: form.year,
            cost: cost
          )
          order = Orders::CreateOrder.new(service: membership_fee).create
          return Failure.new(:wrong_payment) unless order.payment.present?
          Success.new(payment: order.payment)
        else
          return Failure.new(:invalid, form: form)
        end
      end
    end
  end
end
