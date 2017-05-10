class AddRemarksToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :remarks, :text
  end
end
