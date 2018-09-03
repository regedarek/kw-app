class CreatePhotoRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :photo_requests do |t|
      t.integer :photo_competition_id, null: false
      t.integer :user_id, null: false
      t.string :description
      t.timestamps
    end
  end
end
