module Shop
  class OrderRecord < ActiveRecord::Base
    self.table_name = 'shop_orders'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :order_id
    has_many :items, through: :order_items, dependent: :destroy, foreign_key: :item_id

    belongs_to :user, class_name: '::Db::User', foreign_key: :user_id

    accepts_nested_attributes_for :items, :order_items, allow_destroy: true
  end
end
