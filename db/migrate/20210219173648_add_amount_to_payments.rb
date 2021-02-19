class AddAmountToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :amount, :integer
  end
end
