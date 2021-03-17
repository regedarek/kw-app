module Shop
  class OrderItemRecord < ActiveRecord::Base
    self.table_name = 'shop_order_items'

    has_paper_trail

    belongs_to :item, class_name: '::Shop::ItemRecord', foreign_key: :item_id
    belongs_to :order, class_name: '::Shop::OrderRecord', foreign_key: :order_id
    belongs_to :user, class_name: '::Db::User', foreign_key: :user_id
    belongs_to :item_kind, class_name: '::Shop::ItemKindRecord', foreign_key: :item_kind_id
  end
end
