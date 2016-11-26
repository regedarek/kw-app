class AddCanceledToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :canceled, :boolean, default: false
  end
end
