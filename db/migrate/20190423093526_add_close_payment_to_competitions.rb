class AddClosePaymentToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :close_payment, :datetime
  end
end
