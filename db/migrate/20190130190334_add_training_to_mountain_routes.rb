class AddTrainingToMountainRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :mountain_routes, :training, :boolean, default: false, null: false
  end
end
