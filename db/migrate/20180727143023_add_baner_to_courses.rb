class AddBanerToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :baner, :string
  end
end
