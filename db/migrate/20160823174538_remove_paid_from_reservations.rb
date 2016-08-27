class RemovePaidFromReservations < ActiveRecord::Migration
  def change
    remove_column :reservations, :paid, :boolean
    remove_column :reservations, :item_id, :integer
  end
end
