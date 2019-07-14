class AddRentableToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :rentable, :boolean, default: false
  end
end
