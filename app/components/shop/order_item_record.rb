# == Schema Information
#
# Table name: shop_order_items
#
#  id           :bigint           not null, primary key
#  quantity     :integer          default(1), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  item_id      :integer          not null
#  item_kind_id :integer          not null
#  order_id     :integer          not null
#  user_id      :integer          not null
#
module Shop
  class OrderItemRecord < ActiveRecord::Base
    self.table_name = 'shop_order_items'

    has_paper_trail

    belongs_to :item, class_name: '::Shop::ItemRecord', foreign_key: :item_id
    belongs_to :order, class_name: '::Shop::OrderRecord', foreign_key: :order_id
    belongs_to :user, class_name: '::Db::User', foreign_key: :user_id
    belongs_to :item_kind, class_name: '::Shop::ItemKindRecord', foreign_key: :item_kind_id

    def cost
      return 0 unless quantity > 0

      item_kind.price * quantity
    end
  end
end
