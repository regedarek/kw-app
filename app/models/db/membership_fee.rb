module Db
  class MembershipFee < ActiveRecord::Base
    has_one :service, as: :serviceable
    has_one :order, through: :service

    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    def cost
      if order.present?
        if order.payment.try(:cash) || order.payment.try(:prepaid?)
          return 100
        end
      end
      return 150
    end
  end
end
