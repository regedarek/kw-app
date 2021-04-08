class RemoveActivityTypeFromBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    remove_column :business_courses, :activity_type
  end
end
