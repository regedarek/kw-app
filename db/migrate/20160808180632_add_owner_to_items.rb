class AddOwnerToItems < ActiveRecord::Migration
  def change
    add_column :items, :owner, :integer, default: 0
  end
end
