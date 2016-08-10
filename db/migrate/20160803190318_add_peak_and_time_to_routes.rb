class AddPeakAndTimeToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :peak, :string
    add_column :routes, :time, :string
  end
end
