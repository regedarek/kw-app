class AddLengthToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :mountain_routes, :length, :integer
    add_column :mountain_routes, :mountains, :string
  end
end
