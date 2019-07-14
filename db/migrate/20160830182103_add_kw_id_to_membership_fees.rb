class AddKwIdToMembershipFees < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_fees, :kw_id, :integer
  end
end
