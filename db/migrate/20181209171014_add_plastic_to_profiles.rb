class AddPlasticToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :plastic, :boolean, null: false, default: false
  end
end
