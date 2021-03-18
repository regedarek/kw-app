class AddAreaTypeToSettlementContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :area_type, :integer
  end
end
