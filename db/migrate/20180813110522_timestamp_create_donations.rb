class TimestampCreateDonations < ActiveRecord::Migration[5.0]
  def change
    create_table :donations do |t|
      t.belongs_to :user
      t.integer :cost
      t.string :description
      t.timestamps null: false
    end
  end
end
