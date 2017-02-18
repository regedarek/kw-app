class RenameRoutesToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    rename_table :routes, :mountain_routes
  end
end
