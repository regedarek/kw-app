class AddClosedToPhotoCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :photo_competitions, :closed, :boolean, null: false, default: false
  end
end
