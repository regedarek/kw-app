class AddVotingTypeToManagementVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :voting_type, :integer, default: 0, null: false
  end
end
