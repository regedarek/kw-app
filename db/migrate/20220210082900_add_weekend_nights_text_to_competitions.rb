class AddWeekendNightsTextToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :weekend_nights_text, :text
  end
end
