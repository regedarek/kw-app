class AddReactivationToMembershipFees < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_fees, :reactivation, :boolean, default: false
  end
end
