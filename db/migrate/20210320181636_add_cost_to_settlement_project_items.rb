class AddCostToSettlementProjectItems < ActiveRecord::Migration[5.2]
  def change
    add_column :settlement_project_items, :cost, :float
  end
end
