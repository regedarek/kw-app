class AddDocumentNumberToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :document_number, :string
  end
end
