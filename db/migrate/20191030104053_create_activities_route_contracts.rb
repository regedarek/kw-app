class CreateActivitiesRouteContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :activities_route_contracts do |t|
      t.integer :route_id, null: false
      t.integer :contract_id, null: false
      t.timestamps
    end
  end
end
