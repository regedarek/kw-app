class AddLocationToMeteoblueRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :meteoblue_records, :location, :string
  end
end
