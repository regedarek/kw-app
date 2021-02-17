class AddInternalNumberToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :internal_number, :integer
    add_index :contracts, [:internal_number, :period_date], unique: true
  end
end
