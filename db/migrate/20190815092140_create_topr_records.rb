class CreateToprRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :topr_records do |t|
      t.date :time
      t.text :statement
      t.integer :avalanche_degree
      t.timestamps
    end
  end
end
