class AddCoordinatorIdToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :coordinator_id, :integer
  end
end
