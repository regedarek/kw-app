class AddSeriesToActivitiesCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :activities_competitions, :series, :integer
  end
end
