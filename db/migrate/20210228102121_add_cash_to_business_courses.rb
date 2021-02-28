class AddCashToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :cash, :boolean, null: false, default: false
  end
end
