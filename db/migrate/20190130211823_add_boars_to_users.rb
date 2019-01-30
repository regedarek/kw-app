class AddBoarsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :boars, :boolean, default: true, null: false
  end
end
