class RemoveIndexesFromMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    remove_index :mountain_routes, name: "index_mountain_routes_on_created_at"
    remove_index :mountain_routes, name: "index_mountain_routes_complex"
  end
end
