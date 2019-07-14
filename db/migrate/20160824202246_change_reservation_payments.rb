class ChangeReservationPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :reservation_payments, :state, :string
    change_column :reservation_payments, :cash, :boolean, default: false
  end
end
