class AddAreaToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :mountain_routes, :area, :string
  end
end
