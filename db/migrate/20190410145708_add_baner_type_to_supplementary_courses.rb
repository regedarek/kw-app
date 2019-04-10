class AddBanerTypeToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :baner_type, :integer, default: 0, null: false
  end
end
