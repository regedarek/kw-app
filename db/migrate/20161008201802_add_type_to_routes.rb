class AddTypeToRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :routes, :type, :integer, default: 0
  end
end

