class CreateManagementCases < ActiveRecord::Migration[5.2]
  def change
    create_table :management_cases do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :state, null: false, default: 'draft'
      t.text :destrciption
      t.integer :creator_id, null: false
      t.timestamps
    end
    add_index :management_cases, :slug, unique: true
  end
end
