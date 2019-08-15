class AddMeteogramToMeteoblueRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :meteoblue_records, :meteogram, :string
  end
end
