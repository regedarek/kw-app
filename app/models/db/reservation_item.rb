# == Schema Information
#
# Table name: reservation_items
#
#  id             :integer          not null, primary key
#  item_id        :integer
#  reservation_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Db::ReservationItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :reservation
end
