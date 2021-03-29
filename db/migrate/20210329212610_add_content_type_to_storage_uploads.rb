class AddContentTypeToStorageUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :storage_uploads, :content_type, :string
    add_column :storage_uploads, :file_size, :string
  end
end
