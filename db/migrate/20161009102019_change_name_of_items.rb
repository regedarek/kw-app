class ChangeNameOfItems < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :name, :display_name
  end
end
