class AddWarningsToItems < ActiveRecord::Migration
  def change
    add_column :users, :warnings, :integer, default: 0
  end
end
