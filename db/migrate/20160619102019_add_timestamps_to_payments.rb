class AddTimestampsToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :created_at, :timestamp
    add_column :payments, :updated_at, :timestamp
  end
end
