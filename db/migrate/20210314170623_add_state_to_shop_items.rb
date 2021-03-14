class AddStateToShopItems < ActiveRecord::Migration[5.2]
  def change
    add_column :shop_items, :state, :string, null: false, default: 'draft'
    add_timestamps :shop_items, null: true 
  end
end
