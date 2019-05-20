class AddDocumentTypeAndDocumentDateToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :document_type, :integer
    add_column :contracts, :document_date, :date
  end
end
