class AddBankAccountToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :bank_account, :string
  end
end
