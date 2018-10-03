class AddKindToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :kind, :integer, default: 0, null: false
  end
end
