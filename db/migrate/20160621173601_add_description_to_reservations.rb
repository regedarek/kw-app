class AddDescriptionToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :description, :text
  end
end
