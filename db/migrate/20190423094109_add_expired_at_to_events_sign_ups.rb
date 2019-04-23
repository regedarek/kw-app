class AddExpiredAtToEventsSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :expired_at, :datetime
  end
end
