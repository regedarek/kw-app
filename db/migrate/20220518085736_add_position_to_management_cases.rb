class AddPositionToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :position, :integer
  end
end
