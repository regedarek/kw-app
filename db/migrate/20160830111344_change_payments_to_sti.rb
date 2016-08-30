class ChangePaymentsToSti < ActiveRecord::Migration
  def change
    rename_table :reservation_payments, :payments
    add_column :payments, :type, :string
    change_column :payments, :state, :string, default: 'unpaid'
    drop_table :membership_payments
  end
end
