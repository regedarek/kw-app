class ChangeColumnInPayments < ActiveRecord::Migration
  def change
    rename_column :payments, :reservation_id, :resource_id
  end
end
