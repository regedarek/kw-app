class AddRentableToItems < ActiveRecord::Migration
  def change
    add_column :items, :rentable, :boolean, default: false
  end
end
