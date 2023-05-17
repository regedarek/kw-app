class AddCourseCertToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :course_cert, :string
  end
end
