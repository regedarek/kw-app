class AddActionTypeToDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :action_type, :integer
  end
end
