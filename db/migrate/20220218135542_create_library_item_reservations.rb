class CreateLibraryItemReservations < ActiveRecord::Migration[5.2]
  def change
    create_table :library_item_reservations do |t|
      t.integer :item_id, null: false
      t.integer :user_id, null: false
      t.date :returned_at
      t.date :received_at, null: false
      t.integer :caution
      t.text :description
    end
  end
end
