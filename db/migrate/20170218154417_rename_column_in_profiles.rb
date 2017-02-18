class RenameColumnInProfiles < ActiveRecord::Migration[5.0]
  def change
    rename_column :profiles, :section, :sections
  end
end
