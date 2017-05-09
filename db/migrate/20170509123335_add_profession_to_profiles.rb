class AddProfessionToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :profession, :string
  end
end
