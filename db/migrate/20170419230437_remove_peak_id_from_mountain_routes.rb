class RemovePeakIdFromMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    remove_column :mountain_routes, :peak_id, :string
  end
end
