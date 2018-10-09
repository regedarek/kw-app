class AddAreaToPhotoRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :photo_requests, :area, :string
    add_column :photo_requests, :title, :string
  end
end
