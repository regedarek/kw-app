class AddPhotographToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :photograph, :string
  end
end
