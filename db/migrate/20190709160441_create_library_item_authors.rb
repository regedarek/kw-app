class CreateLibraryItemAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :library_item_authors do |t|
      t.integer :item_id
      t.integer :author_id
      t.timestamps
    end
    add_index :library_item_authors, [:item_id , :author_id], :unique => true
  end
end
