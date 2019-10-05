class AddInstructorToBusinessUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :instructor, :string
  end
end
