class AddContractorIdToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :contractor_id, :integer
  end
end
