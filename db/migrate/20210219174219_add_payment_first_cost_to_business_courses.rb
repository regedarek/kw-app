class AddPaymentFirstCostToBusinessCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :business_courses, :payment_first_cost, :integer, null: false, default: 0
    add_column :business_courses, :payment_second_cost, :integer, null: false, default: 0
  end
end
