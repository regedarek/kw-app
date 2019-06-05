class AddSubstantiveTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :substantive_type, :integer
  end
end
