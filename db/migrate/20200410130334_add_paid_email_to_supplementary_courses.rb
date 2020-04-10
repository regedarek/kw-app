class AddPaidEmailToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :paid_email, :text
  end
end
