class CreateSettlementProjectItems < ActiveRecord::Migration[5.2]
  def change
    create_table :settlement_project_items do |t|
      t.string :accountable_type, null: false
      t.integer :accountable_id, null: false
      t.integer :user_id, null: false
    end
    add_index :settlement_project_items, [:accountable_type, :accountable_id], unique: true, name: 'settlement_project_items_uniq'
  end
end
