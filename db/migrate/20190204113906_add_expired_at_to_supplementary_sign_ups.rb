class AddExpiredAtToSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :expired_at, :datetime
  end
end
