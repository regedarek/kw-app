class AddProjectIdToSettlementProjectItems < ActiveRecord::Migration[5.2]
  def change
    add_column :settlement_project_items, :project_id, :integer
  end
end
