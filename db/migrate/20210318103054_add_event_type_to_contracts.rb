class AddEventTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :event_type, :integer
  end
end
