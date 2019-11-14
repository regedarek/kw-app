class CreateActivitiesCompetitions < ActiveRecord::Migration[5.2]
  def change
    create_table :activities_competitions do |t|
      t.string :name, null: false
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :website
      t.integer :creator_id
      t.integer :country, null: false
      t.integer :category_type
      t.string :slug, null: false
      t.string :state, default: "draft", null: false
      t.timestamps null: false
    end
  end
end
