class AddClosedAtToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :closed_at, :datetime
  end
end
