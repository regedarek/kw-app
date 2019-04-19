class AddNullFalseToRouteTime < ActiveRecord::Migration[5.2]
  def change
    change_column :mountain_routes, :route_time, :datetime, null: false
  end
end
