class AddPaidToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :paid, :boolean
  end
end
