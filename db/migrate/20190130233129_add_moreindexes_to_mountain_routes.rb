class AddMoreindexesToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    add_index :mountain_routes, :climbing_date
    add_index :mountain_routes, :created_at
  end
end
