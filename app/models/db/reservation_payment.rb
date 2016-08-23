class Db::ReservationPayment < ActiveRecord::Base
  belongs_to :reservation
end
