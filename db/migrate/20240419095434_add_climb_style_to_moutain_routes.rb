class AddClimbStyleToMoutainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :climb_style, :integer
  end
end
