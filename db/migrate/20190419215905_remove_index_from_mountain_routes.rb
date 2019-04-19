class RemoveIndexFromMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    remove_index :mountain_routes, :route_time
  end
end
