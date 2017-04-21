class ChangeAcomplishedCourses < ActiveRecord::Migration[5.0]
  def change
    change_column :profiles, :acomplished_courses, :text
  end
end
