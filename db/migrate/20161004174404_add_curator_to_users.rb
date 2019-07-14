class AddCuratorToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :curator, :boolean, default: false, null: false
  end
end
