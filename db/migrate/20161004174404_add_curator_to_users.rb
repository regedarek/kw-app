class AddCuratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :curator, :boolean, default: false, null: false
  end
end
