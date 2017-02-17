module Db
  class Order < ActiveRecord::Base
    has_many :services
    has_many :reservations, through: :services, source: :serviceable, source_type: 'Db::Reservation'
    has_many :strzelecki_sign_ups, through: :services, source: :serviceable, source_type: 'Db::Strzelecki::SignUp'
    has_many :membership_fees, through: :services, source: :serviceable, source_type: 'Db::MembershipFee'

    has_one :payment
    belongs_to :user

    def update_cost
      update(cost: reservations.map(&:items).flatten.map(&:cost).reduce(:+))
    end

    def description
      return "Rezerwacja nr: #{services.first.serviceable.id}" if services.first.serviceable.is_a? Db::Reservation
      return "Zapis na zawody MJS 2017 nr #{services.first.serviceable.id} od #{services.first.serviceable.name_1}" if services.first.serviceable.is_a? Db::Strzelecki::SignUp
    end
  end
end
