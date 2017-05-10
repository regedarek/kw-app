class AddAddedToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :added, :boolean, default: false
  end
end
