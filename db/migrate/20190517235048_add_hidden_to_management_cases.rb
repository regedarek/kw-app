class AddHiddenToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :hidden, :boolean, null: false, default: false
  end
end
