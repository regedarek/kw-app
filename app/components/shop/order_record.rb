# == Schema Information
#
# Table name: shop_orders
#
#  id         :bigint           not null, primary key
#  state      :string           default("new"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
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
      order_items.includes(:item_kind).inject(0){|sum,order_item| sum + order_item.cost }
    end

    def description
      "Zakup w sklepiku od #{user.display_name}"
    end

    def payment_type
      :shop
    end
  end
end
