class CreateSettlementProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :settlement_projects do |t|
      t.string :name, null: false
      t.text :description
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
