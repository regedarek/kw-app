class AddMembershipToSupplementaryCoursePackageTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_course_package_types, :membership, :boolean, default: false, null: false
  end
end
