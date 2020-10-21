class AddWhoIdsToManagementUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :who_ids, :string, array: true
  end
end
