class ChangeColumns < ActiveRecord::Migration[5.0]
  def change
  change_column_null :profiles, :birth_date, true
  change_column_null :profiles, :birth_place, true
  change_column_null :profiles, :pesel, true
  change_column_null :profiles, :city, true
  change_column_null :profiles, :postal_code, true
  change_column_null :profiles, :main_address, true
  end
end
