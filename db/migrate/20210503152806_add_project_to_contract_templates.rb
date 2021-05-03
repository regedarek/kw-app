class AddProjectToContractTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :contract_templates, :project, :boolean, null: false, default: false
  end
end
