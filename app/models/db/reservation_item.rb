# == Schema Information
#
# Table name: reservation_items
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  item_id        :integer
#  reservation_id :integer
#
class Db::ReservationItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :reservation
end
