class AddBoldToActivitiesCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :activities_competitions, :bold, :boolean, null: false, default: false
  end
end
