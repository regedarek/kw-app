class AddCostToItems < ActiveRecord::Migration
  def change
    add_column :items, :cost, :integer, default: 0
  end
end
