class AddAgainIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :mountain_routes, :route_time, order: { route_time: :desc }
  end
end
