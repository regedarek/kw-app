class AddEquipmentToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :equipment, :text
  end
end
