class AddNumberToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :number, :string, unique: true, null: true
  end
end
