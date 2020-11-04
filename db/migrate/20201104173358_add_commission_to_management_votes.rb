class AddCommissionToManagementVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :management_votes, :commission, :boolean, null: false, default: false
    add_column :management_votes, :authorized_id, :integer
  end
end
