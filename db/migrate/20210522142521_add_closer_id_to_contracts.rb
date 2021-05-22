class AddCloserIdToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :closer_id, :integer
  end
end
