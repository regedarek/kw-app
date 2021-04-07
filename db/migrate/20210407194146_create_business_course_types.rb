class CreateBusinessCourseTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :business_course_types do |t|
      t.string :name, null: false
      t.string :sign_ups_uri, null: false
      t.integer :logo_type, null: false, default: 0
    end
    add_column :business_courses, :course_type_id, :integer
  end
end
