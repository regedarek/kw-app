class AddWhoIdToManagementVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :management_votes, :who_id, :integer
  end
end
