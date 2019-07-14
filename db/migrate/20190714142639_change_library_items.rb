class ChangeLibraryItems < ActiveRecord::Migration[5.2]
  def change
    rename_column :library_items, :attachements, :attachments
    add_column :library_items, :slug, :string, null: false
  end
end
