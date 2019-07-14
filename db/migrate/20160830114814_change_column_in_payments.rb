class ChangeColumnInPayments < ActiveRecord::Migration[5.0]
  def change
    rename_column :payments, :reservation_id, :resource_id
  end
end
