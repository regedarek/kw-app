class AddRefundedAtToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :refunded_at, :datetime
  end
end
