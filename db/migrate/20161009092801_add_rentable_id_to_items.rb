class AddRentableIdToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :rentable_id, :integer
  end
end
