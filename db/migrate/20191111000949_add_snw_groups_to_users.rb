class AddSnwGroupsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :snw_groups, :string, default: [], array: true
  end
end
