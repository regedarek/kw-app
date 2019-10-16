class AddOriginalFilenameToPhotoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :photo_requests, :original_filename, :string
  end
end
