class AddStravaAthleteIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :strava_athlete_id, :string
  end
end
