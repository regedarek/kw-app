class AddRouteTypeToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :route_type, :integer, default: 0
  end
end

