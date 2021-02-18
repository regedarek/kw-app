class AddSlugToShopItems < ActiveRecord::Migration[5.2]
  def change
    add_column :shop_items, :slug, :string, null: false, uniqe: true
  end
end
