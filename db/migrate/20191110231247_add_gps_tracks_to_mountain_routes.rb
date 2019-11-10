class AddGpsTracksToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :gps_tracks, :string
  end
end
