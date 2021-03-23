class RemoveSizeFromShopOrderItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :shop_order_items, :size
    remove_column :shop_items, :price
  end
end
