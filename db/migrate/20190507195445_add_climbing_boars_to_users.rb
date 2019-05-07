class AddClimbingBoarsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :climbing_boars, :boolean, default: true, null: false
  end
end
