class AddFinalVotesToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :final_voting_result, :string
  end
end
