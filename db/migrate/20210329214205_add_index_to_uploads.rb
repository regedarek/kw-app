class AddIndexToUploads < ActiveRecord::Migration[5.2]
  def change
    add_index :storage_uploads, [:uploadable_id, :uploadable_type]
    add_index :storage_uploads, :user_id
  end
end
