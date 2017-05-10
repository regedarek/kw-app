class AddPositionToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :position, :text, array: true, default: []
  end
end
