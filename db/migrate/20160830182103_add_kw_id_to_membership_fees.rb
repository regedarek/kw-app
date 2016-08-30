class AddKwIdToMembershipFees < ActiveRecord::Migration
  def change
    add_column :membership_fees, :kw_id, :integer
  end
end
