class AddParticipantPhoneToEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :participant_phone_1, :string
    add_column :events_sign_ups, :participant_phone_2, :string
  end
end
