class ChangeNullInEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    change_column_null :events_sign_ups, :competition_package_type_2_id, true
  end
end
