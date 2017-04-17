class ChangePaymentInMembershipFees < ActiveRecord::Migration[5.0]
  def change
    change_column :membership_fees, :payment_id, :integer, null: false
  end
end
