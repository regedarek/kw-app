class AddQuestionToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :question, :boolean, null: false, default: false
  end
end
