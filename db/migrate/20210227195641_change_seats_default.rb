class ChangeSeatsDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :business_courses, :seats, 0
  end
end
