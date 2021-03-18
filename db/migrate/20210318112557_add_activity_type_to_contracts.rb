class AddActivityTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :contracts, :activity_type
    add_column :contracts, :activity_type, :integer
  end
end
