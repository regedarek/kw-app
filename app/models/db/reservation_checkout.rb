class Db::ReservationCheckout < ActiveRecord::Base
  belongs_to :item
  belongs_to :reservation
end
