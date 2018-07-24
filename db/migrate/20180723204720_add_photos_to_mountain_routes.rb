class AddPhotosToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :mountain_routes, :attachments, :string
  end
end
