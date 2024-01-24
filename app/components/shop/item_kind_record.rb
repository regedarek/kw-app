# == Schema Information
#
# Table name: shop_item_kinds
#
#  id       :bigint           not null, primary key
#  name     :string
#  price    :float
#  quantity :integer          default(1), not null
#  item_id  :integer          not null
#
module Shop
  class ItemKindRecord < ActiveRecord::Base
    self.table_name = 'shop_item_kinds'

    belongs_to :item, class_name: '::Shop::ItemRecord', foreign_key: :item_id
    has_many :order_items, class_name: '::Shop::OrderItemRecord', foreign_key: :item_kind_id
  end
end
