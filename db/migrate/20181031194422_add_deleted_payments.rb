class AddDeletedPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :deleted, :boolean, null: false, default: false
  end
end
