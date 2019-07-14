class AddWarningsToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :warnings, :integer, default: 0
  end
end
