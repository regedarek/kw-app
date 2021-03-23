module Shop
  class OrderRecord < ActiveRecord::Base
    include Workflow
    has_paper_trail
    self.table_name = 'shop_orders'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :order_id
    has_many :items, through: :order_items, dependent: :destroy, foreign_key: :item_id

    belongs_to :user, class_name: '::Db::User', foreign_key: :user_id
    has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'

    accepts_nested_attributes_for :items, :order_items, allow_destroy: true

    workflow_column :state
    workflow do
      state :new do
        event :close, :transitions_to => :closed
      end
      state :closed
    end

    def cost
      items.inject(0){|sum,item| sum + item.price }
    end

    def description
      "Zakup w sklepiku od #{user.display_name}"
    end

    def payment_type
      :shop
    end

  end
end
