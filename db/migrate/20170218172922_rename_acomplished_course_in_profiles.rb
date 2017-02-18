class RenameAcomplishedCourseInProfiles < ActiveRecord::Migration[5.0]
  def change
    rename_column :profiles, :acomplished_course, :acomplished_courses
  end
end
