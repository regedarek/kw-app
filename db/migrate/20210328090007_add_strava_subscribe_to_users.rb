class AddStravaSubscribeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :strava_subscribe, :boolean, null: false, default: false
  end
end
