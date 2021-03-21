class AddStateToShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :shop_orders, :state, :string, null: false, default: 'new'
  end
end
