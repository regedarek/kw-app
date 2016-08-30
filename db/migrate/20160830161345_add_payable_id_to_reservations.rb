class AddPayableIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :payable_id, :integer
  end
end
