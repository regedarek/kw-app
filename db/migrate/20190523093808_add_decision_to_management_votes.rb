class AddDecisionToManagementVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :management_votes, :decision, :string
  end
end
