class AddHideVotesToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :hide_votes, :boolean, null: false, default: false
  end
end
