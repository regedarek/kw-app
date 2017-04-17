class AddPayableTypeToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :payable_type, :string
  end
end
