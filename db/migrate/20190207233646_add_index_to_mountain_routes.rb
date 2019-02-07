class AddIndexToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_index :mountain_routes, [:name, :route_type, :rating, :length, :created_at, :climbing_date], name: 'index_mountain_routes_complex'
  end
end
