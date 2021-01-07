class AddPublicToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :public, :boolean, null: false, default: false
  end
end
