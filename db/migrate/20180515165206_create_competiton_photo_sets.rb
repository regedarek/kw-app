class CreateCompetitonPhotoSets < ActiveRecord::Migration[5.0]
  def change
    create_table :competiton_photo_sets do |t|
      t.string :name
      t.timestamps
    end
  end
end
