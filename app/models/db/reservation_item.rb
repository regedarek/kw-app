class Db::ReservationItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :reservation
end
