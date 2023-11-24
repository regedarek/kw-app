class AddLikesCountToPhotoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :photo_requests, :likes_count, :integer, default: 0, null: false
    add_column :photo_requests, :accepted, :boolean, default: false, null: false
  end
end
