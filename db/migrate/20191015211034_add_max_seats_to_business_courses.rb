class AddMaxSeatsToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :max_seats, :integer
    add_column :business_courses, :sign_up_url, :string
  end
end
