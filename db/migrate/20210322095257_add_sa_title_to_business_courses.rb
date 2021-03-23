class AddSaTitleToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :sa_title, :string
  end
end
