class ChangeTimestampsInShopItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :shop_items, :created_at
    remove_column :shop_items, :updated_at
    add_column :shop_items, :created_at, :datetime, null: false
    add_column :shop_items, :updated_at, :datetime, null: false
  end
end
