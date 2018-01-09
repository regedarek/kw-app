class AddKwIdToEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :participant_kw_id_1, :integer
    add_column :events_sign_ups, :participant_kw_id_2, :integer
  end
end
