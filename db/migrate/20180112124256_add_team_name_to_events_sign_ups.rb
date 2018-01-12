class AddTeamNameToEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :team_name, :string
  end
end
