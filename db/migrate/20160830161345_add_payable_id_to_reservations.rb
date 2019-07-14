class AddPayableIdToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :payable_id, :integer
  end
end
