module Db
  class Order < ActiveRecord::Base
    has_many :services
    has_many :reservations, through: :services, source: :serviceable, source_type: 'Db::Reservation'

    has_one :payment
    belongs_to :user

    def cost
      # todo: right now we have only reservations
      reservations.map(&:items).flatten.map(&:cost).reduce(:+)
    end
  end
end
