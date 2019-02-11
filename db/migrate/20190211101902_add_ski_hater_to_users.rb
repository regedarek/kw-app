class AddSkiHaterToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ski_hater, :boolean, null: false, default: false
  end
end
