class CreateShopItems < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_items do |t|
      t.string :name
      t.text :description
      t.float :price
    end
  end
end
