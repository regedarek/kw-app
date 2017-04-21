class UpdateAcomplishedCourses < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :acomplished_courses
    add_column :profiles, :acomplished_courses, :text, array: true, default: []
  end
end
