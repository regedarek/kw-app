class CreateActivitiesContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :activities_contracts do |t|
      t.string :name, null: false
      t.text :description
      t.integer :score, null: false, default: 0
      t.timestamps
    end
  end
end
