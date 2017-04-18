class FixTimestampsForMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:mountain_routes, :created_at, nil)
    change_column_default(:mountain_routes, :updated_at, nil)
  end
end
