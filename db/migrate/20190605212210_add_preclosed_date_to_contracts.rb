class AddPreclosedDateToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :preclosed_date, :datetime
  end
end
