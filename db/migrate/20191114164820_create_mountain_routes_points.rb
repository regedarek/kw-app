class CreateMountainRoutesPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :mountain_routes_points do |t|
      t.text :description
      t.decimal :lat, precision: 10, scale: 6, null: false
      t.decimal :lng, precision: 10, scale: 6, null: false
      t.integer :mountain_route_id, null: false
      t.timestamps null: false
    end
  end
end
