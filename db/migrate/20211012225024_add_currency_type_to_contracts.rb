class AddCurrencyTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :currency_type, :integer, null: false, default: 0
  end
end
