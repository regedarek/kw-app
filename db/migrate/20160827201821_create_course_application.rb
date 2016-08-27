class CreateCourseApplication < ActiveRecord::Migration
  def change
    create_table :course_applications do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.text :living_address
      t.string :birthday
      t.string :birthplace
      t.string :pesel
      t.text :main_adress
      t.text :description
    end
  end
end
