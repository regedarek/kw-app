class CreateBusinessListCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :business_list_courses do |t|
      t.integer :course_id, null: false
      t.integer :list_id, null: false
      t.timestamps
    end

    add_index :business_list_courses, [:course_id, :list_id], unique: true
  end
end
