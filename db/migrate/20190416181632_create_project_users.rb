class CreateProjectUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :project_users do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_index :project_users, [:project_id, :user_id], unique: true
  end
end
