class RemoveNameFromBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    remove_column :business_courses, :name
  end
end
