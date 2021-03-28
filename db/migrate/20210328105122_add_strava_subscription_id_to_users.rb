class AddStravaSubscriptionIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :strava_subscription_id, :string
  end
end
