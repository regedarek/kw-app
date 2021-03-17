class CreateShopOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :shop_orders do |t|
      t.integer :user_id, null: false
      t.timestamps null: false
    end
  end
end
