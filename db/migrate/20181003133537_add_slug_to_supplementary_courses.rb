class AddSlugToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :slug, :string
  end
end
