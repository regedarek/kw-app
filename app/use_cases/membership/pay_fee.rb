module Membership
  class PayFee
    class << self
      def pay(kw_id:, form:)
        if form.valid?
          cost = 150
          last_year_fee = Db::MembershipFee.where(kw_id: kw_id, year: Date.today.last_year.year).first
          this_year_fee = Db::MembershipFee.where(kw_id: kw_id, year: Date.today.year).first
          if last_year_fee.present?
            if this_year_fee.present?
              if this_year_fee.order.present?
                if this_year_fee.order.payment.try(:cash) || this_year_fee.order.payment.try(:prepaid?)
                  cost = 100
                end
              end
            end
            if last_year_fee.order.present?
              if last_year_fee.order.payment.try(:cash) || last_year_fee.order.payment.try(:prepaid?)
                cost = 100
              end
            end
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
