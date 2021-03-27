class AddMapSummaryPolylineToMountainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :map_summary_polyline, :string
  end
end
