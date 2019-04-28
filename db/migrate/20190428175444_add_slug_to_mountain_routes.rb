class AddSlugToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :slug, :string
    add_index :mountain_routes, :slug, unique: true
  end
end
