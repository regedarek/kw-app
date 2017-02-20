module Membership
  class PayFee
    class << self
      def pay(kw_id:, form:)
        if form.valid?
          membership_fee = Db::MembershipFee.create(
            kw_id: kw_id,
            year: form.year,
            reactivation: form.reactivation
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
