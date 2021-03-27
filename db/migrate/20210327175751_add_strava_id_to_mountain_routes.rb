class AddStravaIdToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :strava_id, :string
  end
end
