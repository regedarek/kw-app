class AddBackAtToLibraryReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :library_item_reservations, :back_at, :date
  end
end
