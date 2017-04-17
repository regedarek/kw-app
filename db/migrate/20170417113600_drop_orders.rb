class DropOrders < ActiveRecord::Migration[5.0]
  def change
    drop_table :orders
    drop_table :services
    remove_column :payments, :order_id
  end
end
