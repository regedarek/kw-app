class AddRouteTimeToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :route_time, :datetime
    add_index :mountain_routes, :route_time, order: { route_time: :desc }
  end
end
