class AddDistanceToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :distance, :float
  end
end
