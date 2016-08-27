class ChangeReservationPayments < ActiveRecord::Migration
  def change
    add_column :reservation_payments, :state, :string
    change_column :reservation_payments, :cash, :boolean, default: false
  end
end
