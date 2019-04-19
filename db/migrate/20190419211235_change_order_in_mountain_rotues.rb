class ChangeOrderInMountainRotues < ActiveRecord::Migration[5.2]
  def change
    remove_index :mountain_routes, name: "index_mountain_routes_on_climbing_date"
    add_index :mountain_routes, :climbing_date, order: { climbing_date: :desc }
  end
end
