class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.string :file_filename
      t.integer :file_size
      t.string :file_content_type
      t.timestamps
    end
  end
end
