class CreateRouteColleagues < ActiveRecord::Migration[5.0]
  def change
    create_table :route_colleagues do |t|
      t.integer :colleague_id
      t.integer :mountain_route_id
    end
  end
end
