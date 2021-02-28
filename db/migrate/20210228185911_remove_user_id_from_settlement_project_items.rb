class RemoveUserIdFromSettlementProjectItems < ActiveRecord::Migration[5.2]
  def change
    change_column :settlement_project_items, :user_id, :integer, null: false
  end
end
