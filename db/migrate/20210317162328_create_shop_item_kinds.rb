class CreateShopItemKinds < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_item_kinds do |t|
      t.string :name
      t.integer :quantity, null: false, default: 1
      t.integer :item_id, null: false
    end
    add_column :shop_order_items, :item_kind_id, :integer, null: false
  end
end
