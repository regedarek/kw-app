class AddCostToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :cost, :integer, default: 0
  end
end
