class CreatePhotoRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :photo_requests do |t|
      t.integer :edition_record_id, null: false
      t.integer :user_id, null: false
      t.string :description
      t.timestamps
    end
  end
end
