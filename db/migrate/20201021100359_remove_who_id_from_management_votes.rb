class RemoveWhoIdFromManagementVotes < ActiveRecord::Migration[5.2]
  def change
    remove_column :management_votes, :who_id
  end
end
