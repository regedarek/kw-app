class RenamePayments < ActiveRecord::Migration[5.0]
  def change
    rename_table :payments, :membership_payments
  end
end
