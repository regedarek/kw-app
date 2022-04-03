class AddDeliverFieldsToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :document_deliver, :boolean, null: false, default: false
    add_column :contracts, :accountant_deliver, :boolean, null: false, default: false
  end
end
