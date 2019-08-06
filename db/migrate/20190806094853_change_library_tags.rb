class ChangeLibraryTags < ActiveRecord::Migration[5.2]
  def change
    rename_table :library_areas, :library_tags
    add_column :library_tags, :parent_id, :integer
    add_column :library_tags, :type, :integer
  end
end
