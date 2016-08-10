class AddPaidToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :paid, :boolean
  end
end
