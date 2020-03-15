class AddEventIdToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :event_id, :integer
  end
end
