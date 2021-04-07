class AddTypeSymToBusinessCourseTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :business_course_types, :type_sym, :string, null: false
  end
end
