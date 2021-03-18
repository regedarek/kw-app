class AddCheckerIdToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :checker_id, :integer
  end
end
