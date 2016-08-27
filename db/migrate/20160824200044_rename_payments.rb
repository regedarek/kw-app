class RenamePayments < ActiveRecord::Migration
  def change
    rename_table :payments, :membership_payments
  end
end
