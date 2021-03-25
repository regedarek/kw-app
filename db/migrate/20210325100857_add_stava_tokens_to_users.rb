class AddStavaTokensToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :strava_access_token, :string
    add_column :users, :strava_refresh_token, :string
  end
end
