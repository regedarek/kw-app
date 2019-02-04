class AddExpiredHoursToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :expired_hours, :integer, null: false, default: 0
  end
end
