class AddEmailToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :email, :string, unique: true
  end
end
