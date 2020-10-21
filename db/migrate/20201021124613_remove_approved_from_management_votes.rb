class RemoveApprovedFromManagementVotes < ActiveRecord::Migration[5.2]
  def change
    remove_column :management_votes, :approved
    change_column_null(:management_votes, :decision, false, 0)
  end
end
