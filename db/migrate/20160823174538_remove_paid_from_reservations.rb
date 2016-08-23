class RemovePaidFromReservations < ActiveRecord::Migration
  def change
    remove_column :reservations, :paid, :item_id
  end
end
