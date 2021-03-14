class RemoveUserIdFromStorageUploads < ActiveRecord::Migration[5.2]
  def change
    change_column_null :storage_uploads, :user_id, true
  end
end
