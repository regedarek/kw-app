class RenameReservationCheckoutToReservationItems < ActiveRecord::Migration
  def change
    rename_table :reservation_checkouts, :reservation_items
  end
end
