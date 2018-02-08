class AddCreatorIdToMembershipFees < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_fees, :creator_id, :integer
  end
end
