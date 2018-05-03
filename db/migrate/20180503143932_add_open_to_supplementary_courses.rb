class AddOpenToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :open, :boolean, null: false, default: true
  end
end
