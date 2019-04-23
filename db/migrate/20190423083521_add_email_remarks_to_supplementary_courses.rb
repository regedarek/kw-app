class AddEmailRemarksToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :email_remarks, :text
  end
end
