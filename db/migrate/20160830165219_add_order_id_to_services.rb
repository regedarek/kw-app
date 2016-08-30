class AddOrderIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :order_id, :integer
  end
end
