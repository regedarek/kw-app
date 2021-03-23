class AddPriceToShopItemKinds < ActiveRecord::Migration[5.2]
  def change
    add_column :shop_item_kinds, :price, :float
  end
end
