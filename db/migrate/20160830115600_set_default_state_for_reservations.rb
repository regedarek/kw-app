class SetDefaultStateForReservations < ActiveRecord::Migration
  def change
    change_column :reservations, :state, :string, default: 'reserved'
  end
end
