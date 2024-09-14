class AddTimestampsToStorageUploads < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :storage_uploads, null: false, default: -> { 'NOW()' }
  end
end
