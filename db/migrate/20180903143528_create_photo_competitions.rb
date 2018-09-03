class CreatePhotoCompetitions < ActiveRecord::Migration[5.0]
  def change
    create_table :photo_competitions do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.timestamps
    end
  end
end
