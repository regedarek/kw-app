class ShopOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_order_items do |t|
      t.integer :user_id, null: false
      t.integer :order_id, null: false
      t.integer :item_id, null: false
      t.integer :quantity, null: false, default: 1
      t.string :size
      t.timestamps null: false
    end
  end
end
