class AddPaymentTypeToSupplementaryCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_courses, :payment_type, :integer, default: 0, null: false
  end
end
