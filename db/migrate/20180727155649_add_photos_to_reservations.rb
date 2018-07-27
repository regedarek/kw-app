class AddPhotosToReservations < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :photos, :string
  end
end
