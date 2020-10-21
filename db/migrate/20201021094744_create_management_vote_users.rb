class CreateManagementVoteUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :management_vote_users do |t|
      t.integer :user_id
      t.integer :vote_id
      t.timestamps
    end
  end
end
