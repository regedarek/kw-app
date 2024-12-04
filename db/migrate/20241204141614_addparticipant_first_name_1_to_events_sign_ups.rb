class AddparticipantFirstName1ToEventsSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :participant_first_name_1, :string
  end
end
