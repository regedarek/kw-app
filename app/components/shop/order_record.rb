module Shop
  class OrderRecord < ActiveRecord::Base
    self.table_name = 'shop_orders'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :order_id
    has_many :items, through: :order_items, dependent: :destroy, foreign_key: :item_id
  end
end
