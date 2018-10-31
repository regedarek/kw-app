class AddCashUserIdToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :cash_user_id, :integer
  end
end
