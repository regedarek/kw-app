class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description
      t.string :instructor
      t.integer :cost, null: false
      t.timestamps
    end
  end
end
