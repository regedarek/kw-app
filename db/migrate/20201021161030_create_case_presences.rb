class CreateCasePresences < ActiveRecord::Migration[5.2]
  def change
    create_table :case_presences do |t|
      t.integer :user_id, null: false
      t.timestamps
    end
    add_index :case_presences, :user_id, unique: true
  end
end
