class AddEventDateToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :event_date, :datetime
  end
end
