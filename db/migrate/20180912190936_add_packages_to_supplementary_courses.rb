class AddPackagesToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :packages, :boolean, default: false
  end
end
