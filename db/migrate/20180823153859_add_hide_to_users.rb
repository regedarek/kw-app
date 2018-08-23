class AddHideToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :hide, :boolean, default: false
  end
end
