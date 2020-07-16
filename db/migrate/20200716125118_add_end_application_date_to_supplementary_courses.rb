class AddEndApplicationDateToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :end_application_date, :datetime
  end
end
