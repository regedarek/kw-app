class AddBankAccountOwnerToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :bank_account_owner, :string
  end
end
