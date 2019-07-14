class RenameReservationCheckoutToReservationItems < ActiveRecord::Migration[5.0]
  def change
    rename_table :reservation_checkouts, :reservation_items
  end
end
