class RemovePaymentIdFromMembershipFees < ActiveRecord::Migration[5.0]
  def change
    remove_column :membership_fees, :payment_id
  end
end
