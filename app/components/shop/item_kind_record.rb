module Shop
  class ItemKindRecord < ActiveRecord::Base
    self.table_name = 'shop_item_kinds'

    belongs_to :item, class_name: '::Shop::ItemRecord', foreign_key: :item_id
    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :item_kind_id
  end
end
