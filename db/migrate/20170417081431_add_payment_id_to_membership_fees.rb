class AddPaymentIdToMembershipFees < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_fees, :payment_id, :integer
  end
end
