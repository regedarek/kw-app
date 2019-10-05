class AddInstructorIdToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :instructor_id, :integer
  end
end
