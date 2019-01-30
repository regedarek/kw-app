class AddIndexesToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
     add_index :mountain_routes, :user_id
     add_index :route_colleagues, [:colleague_id, :mountain_route_id], unique: true
  end
end
