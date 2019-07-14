class RemoveUserIdFromMembershipFees < ActiveRecord::Migration[5.0]
  def change
    remove_column :membership_fees, :user_id
    add_index :membership_fees, :kw_id
  end
end
