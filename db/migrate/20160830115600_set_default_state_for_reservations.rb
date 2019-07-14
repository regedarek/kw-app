class SetDefaultStateForReservations < ActiveRecord::Migration[5.0]
  def change
    change_column :reservations, :state, :string, default: 'reserved'
  end
end
