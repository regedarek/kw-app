class AddGroupTypeToSettlementContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :group_type, :integer
  end
end
