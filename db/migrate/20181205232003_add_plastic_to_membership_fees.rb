class AddPlasticToMembershipFees < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_fees, :plastic, :boolean, null: false, default: false
  end
end
