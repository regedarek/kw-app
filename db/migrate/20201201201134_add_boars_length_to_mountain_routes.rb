class AddBoarsLengthToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :boar_length, :integer, default: 0
  end
end
