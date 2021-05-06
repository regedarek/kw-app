class AddDescriptionToContractTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :contract_templates, :description, :text
  end
end
