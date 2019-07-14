class RemoveAndRenameForPayments < ActiveRecord::Migration[5.0]
  def change
    remove_column :reservations, :payable_id
    rename_column :payments, :resource_id, :order_id
    remove_column :payments, :type
  end
end
