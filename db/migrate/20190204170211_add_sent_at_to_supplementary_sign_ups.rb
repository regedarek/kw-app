class AddSentAtToSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :sent_at, :datetime
  end
end
