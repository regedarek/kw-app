class AddIndexToUploads < ActiveRecord::Migration[5.2]
  def change
    add_index :storage_uploads, [:uploadable_id, :uploadable_type]
    add_index :storage_uploads, :user_id
    Storage::UploadRecord.where(content_type: nil).each{|u| u.update(content_type: u.file.content_type, file_size: u.file.size) }
  end
end
