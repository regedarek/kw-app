class AddOrderIdToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :order_id, :integer
  end
end
