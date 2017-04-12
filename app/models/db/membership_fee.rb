module Db
  class MembershipFee < ActiveRecord::Base
    has_one :service, as: :serviceable
    has_one :order, through: :service

    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    def cost
      last_year_fee = current_user.membership_fees.find_by(year: Date.today.last_year.year)
      if last_year_fee.present?
        if last_year_fee.order.present?
          if last_year_fee.order.payment.try(:cash) || last_year_fee.order.payment.try(:prepaid?)
            return 100
          end
        end
      end
      return 150
    end
  end
end
