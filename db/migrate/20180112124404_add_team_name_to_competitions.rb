class AddTeamNameToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :team_name, :boolean, null: false, default: false
  end
end
