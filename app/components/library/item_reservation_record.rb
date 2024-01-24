# == Schema Information
#
# Table name: library_item_reservations
#
#  id          :bigint           not null, primary key
#  back_at     :date
#  back_by     :integer
#  caution     :integer
#  description :text
#  received_at :date             not null
#  returned_at :date
#  item_id     :integer          not null
#  user_id     :integer          not null
#
module Library
  class ItemReservationRecord < ActiveRecord::Base
    self.table_name = 'library_item_reservations'

    belongs_to :item, class_name: 'Library::ItemRecord', foreign_key: :item_id
    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
    belongs_to :back_by, class_name: 'Db::User', foreign_key: :back_by
  end
end
