class AddDisplayNameToDonations < ActiveRecord::Migration[5.0]
  def change
    add_column :donations, :display_name, :string
  end
end
