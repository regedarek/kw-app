class AddRemoveIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :settlement_project_items, name: 'settlement_project_items_uniq'
    add_index :settlement_project_items, [:accountable_id, :project_id], unique: true
    add_index :settlement_project_items, :user_id
  end
end
