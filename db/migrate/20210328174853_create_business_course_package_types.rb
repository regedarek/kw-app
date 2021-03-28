class CreateBusinessCoursePackageTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :business_course_package_types do |t|
      t.string :name, null: false
      t.integer :business_course_record_id, null: false
      t.integer :cost, null: false
      t.boolean :increase_limit, null: false, default: false
      t.boolean :membership, null: false, default: false
      t.timestamps
    end
    add_column :business_sign_ups, :business_course_package_type_id, :integer
    add_column :business_courses, :packages, :boolean, null: false, default: false
  end
end
