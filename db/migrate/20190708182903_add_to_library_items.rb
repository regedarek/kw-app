class AddToLibraryItems < ActiveRecord::Migration[5.2]
  def change
    add_column :library_items, :item_id, :integer
    add_column :library_items, :reading_room, :boolean
    add_column :library_items, :autors, :string
    add_column :library_items, :publishment_at, :date
    add_column :library_items, :number, :string
  end
end
