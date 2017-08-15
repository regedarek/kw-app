class AddHiddenToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :mountain_routes, :hidden, :boolean, default: false, null: false
  end
end
