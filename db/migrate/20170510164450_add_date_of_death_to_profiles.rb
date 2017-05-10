class AddDateOfDeathToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :date_of_death, :date
  end
end
