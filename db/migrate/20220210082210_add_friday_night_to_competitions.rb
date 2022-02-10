class AddFridayNightToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :weekend_nights, :boolean, null: false, default: false
    add_column :events_sign_ups, :friday_night, :boolean, null: false, default: false
    add_column :events_sign_ups, :saturday_night, :boolean, null: false, default: false
  end
end
