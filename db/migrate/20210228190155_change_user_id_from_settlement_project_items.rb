class ChangeUserIdFromSettlementProjectItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :settlement_project_items, :user_id
    add_column :settlement_project_items, :user_id, :integer
  end
end
