class AddPhotoToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :photo, :string
  end
end
