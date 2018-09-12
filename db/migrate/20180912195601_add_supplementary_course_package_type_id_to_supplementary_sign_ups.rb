class AddSupplementaryCoursePackageTypeIdToSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :supplementary_course_package_type_id, :integer
  end
end
