class AddPeakIdToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :peak_id, :integer
  end
end
