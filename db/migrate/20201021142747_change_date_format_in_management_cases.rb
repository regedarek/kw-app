class ChangeDateFormatInManagementCases < ActiveRecord::Migration[5.2]
  def change
    change_column :management_cases, :acceptance_date, :datetime
  end
end
