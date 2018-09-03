class AddFileToPhotoRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :photo_requests, :file, :string
  end
end
