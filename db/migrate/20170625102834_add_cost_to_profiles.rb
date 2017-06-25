class AddCostToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :cost, :integer
  end
end
