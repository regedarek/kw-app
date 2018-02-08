class AddPaymentUrlToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :payment_url, :string
  end
end
