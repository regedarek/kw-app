class AddPayoutTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :payout_type, :integer
  end
end
