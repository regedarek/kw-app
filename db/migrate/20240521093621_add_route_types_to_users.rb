class AddRouteTypesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ski, :boolean, default: true, null: false
    add_column :users, :regular_climbing, :boolean, default: true, null: false
    add_column :users, :trad_climbing, :boolean, default: false, null: false
    add_column :users, :sport_climbing, :boolean, default: false, null: false
  end
end
