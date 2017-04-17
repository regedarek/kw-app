class AddPayableIdToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :payable_id, :integer
  end
end
