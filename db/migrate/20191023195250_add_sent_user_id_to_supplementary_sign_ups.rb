class AddSentUserIdToSupplementarySignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_sign_ups, :sent_user_id, :integer
  end
end
