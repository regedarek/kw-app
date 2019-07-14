class AddPeakAndTimeToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :peak, :string
    add_column :routes, :time, :string
  end
end
