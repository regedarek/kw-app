class AddContractTemplateIdToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :contract_template_id, :integer
  end
end
