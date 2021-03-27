class AddStravaAccessTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :strava_client_id, :string
    add_column :users, :strava_client_secret, :string
    add_column :users, :strava_expires_at, :datetime
  end
end
