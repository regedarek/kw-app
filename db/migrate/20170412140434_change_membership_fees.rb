class ChangeMembershipFees < ActiveRecord::Migration[5.0]
  def change
    remove_column :membership_fees, :reactivation
    change_column :membership_fees, :cost, :integer, :default => nil, null: false
  end
end
