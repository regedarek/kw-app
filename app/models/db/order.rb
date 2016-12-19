module Db
  class Order < ActiveRecord::Base
    has_many :services
    has_many :reservations, through: :services, source: :serviceable, source_type: 'Db::Reservation'
    has_many :membership_fees, through: :services, source: :serviceable, source_type: 'Db::MembershipFee'

    has_one :payment
    belongs_to :user

    def update_cost
      update(cost: reservations.map(&:items).flatten.map(&:cost).reduce(:+))
    end
  end
end
