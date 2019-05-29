class AddFinancialTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :financial_type, :integer
  end
end
