class AddIndexToManagementVotes < ActiveRecord::Migration[5.2]
  def change
    add_index :management_votes, [:user_id, :case_id], unique: true
  end
end
