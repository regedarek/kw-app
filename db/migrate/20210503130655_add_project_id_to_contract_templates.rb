class AddProjectIdToContractTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :contract_templates, :project_id, :integer
  end
end
