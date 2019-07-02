class CreateLibraryItems < ActiveRecord::Migration[5.2]
  def change
    create_table :library_items do |t|
      t.string :title
      t.text :description
      t.string :attachements
      t.integer :area_id
      t.integer :doc_type
      t.timestamps
    end
  end
end
