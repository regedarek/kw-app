class SetDefaultDecisionInManagementVotes < ActiveRecord::Migration[5.2]
  def change
    change_column :management_votes, :decision, :string, null: false, :default => 'approved'
  end
end
