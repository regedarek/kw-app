class AddActivityTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :activity_type, :integer
  end
end
