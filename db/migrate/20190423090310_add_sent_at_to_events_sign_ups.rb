class AddSentAtToEventsSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :sent_at, :datetime
  end
end
