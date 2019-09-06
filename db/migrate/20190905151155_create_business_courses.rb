class CreateBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :business_courses do |t|
      t.string :name, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.text :description
      t.integer :seats, null: false, default: 1
      t.integer :creator_id
      t.integer :activity_type, null: false
      t.timestamps
    end
  end
end
