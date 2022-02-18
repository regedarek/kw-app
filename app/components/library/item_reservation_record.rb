module Library
  class ItemReservationRecord < ActiveRecord::Base
    self.table_name = 'library_item_reservations'

    belongs_to :item, class_name: 'Library::ItemRecord', foreign_key: :item_id
    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
  end
end
