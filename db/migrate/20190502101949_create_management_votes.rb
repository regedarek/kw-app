class CreateManagementVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :management_votes do |t|
      t.integer :user_id, null: false
      t.integer :case_id, null: false
      t.boolean :approved, null: false, default: false
      t.timestamps
    end
  end
end
