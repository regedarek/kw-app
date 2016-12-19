class AddCostToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :cost, :integer
  end
end
