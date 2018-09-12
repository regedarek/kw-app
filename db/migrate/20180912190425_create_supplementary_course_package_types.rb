class CreateSupplementaryCoursePackageTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :supplementary_course_package_types do |t|
      t.string :name, null: false
      t.integer :supplementary_course_record_id, null: false
      t.integer :cost, null: false
      t.boolean :increase_limit, null: false, default: false
      t.timestamps
    end
  end
end
