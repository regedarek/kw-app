class AddPaidEmailSentAtToSupplementarySignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_sign_ups, :paid_email_sent_at, :datetime
  end
end
