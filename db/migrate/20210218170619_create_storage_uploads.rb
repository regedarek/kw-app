class CreateStorageUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :storage_uploads do |t|
      t.string :file, null: false
      t.integer :uploadable_id, null: false
      t.string :uploadable_type, null: false
      t.integer :user_id, null: false
    end
  end
end
