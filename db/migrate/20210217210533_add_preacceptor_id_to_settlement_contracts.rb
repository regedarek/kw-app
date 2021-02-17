class AddPreacceptorIdToSettlementContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :preacceptor_id, :integer
  end
end
