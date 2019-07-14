class CreateReservationCheckouts < ActiveRecord::Migration[5.0]
  def change
    create_table :reservation_checkouts do |t|
      t.integer :item_id
      t.integer :reservation_id
      t.timestamps
    end
  end
end
