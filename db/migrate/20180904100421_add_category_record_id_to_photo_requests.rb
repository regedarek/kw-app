class AddCategoryRecordIdToPhotoRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :photo_requests, :category_record_id, :integer, null: false
  end
end
