class AddOwnerToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :owner, :integer, default: 0
  end
end
