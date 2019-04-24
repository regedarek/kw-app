class RemoveRouteTimeFromMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    remove_column :mountain_routes, :route_time
  end
end
