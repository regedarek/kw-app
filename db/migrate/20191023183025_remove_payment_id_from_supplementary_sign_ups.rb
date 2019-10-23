class RemovePaymentIdFromSupplementarySignUps < ActiveRecord::Migration[5.2]
  def change
    remove_column :supplementary_sign_ups, :payment_id
  end
end
