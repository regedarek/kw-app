class AddPeakIdToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :peak_id, :integer
  end
end
