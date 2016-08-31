class RemoveUserIdFromMembershipFees < ActiveRecord::Migration
  def change
    remove_column :membership_fees, :user_id
    add_index :membership_fees, :kw_id
  end
end
