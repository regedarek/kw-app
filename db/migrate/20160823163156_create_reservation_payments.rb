class CreateReservationPayments < ActiveRecord::Migration
  def change
    create_table :reservation_payments do |t|
      t.integer :reservation_id
      t.boolean :cash
      t.string :dotpay_id
      t.timestamps
    end
  end
end
