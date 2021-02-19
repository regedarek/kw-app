class AddEmailFirstContentToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :email_first_content, :text
    add_column :business_courses, :email_second_content, :text
  end
end
