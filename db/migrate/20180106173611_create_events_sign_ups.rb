class CreateEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    create_table :events_sign_ups do |t|
      t.text :remarks
      t.integer :competition_id, uniq: true, null: false
      t.string :participant_name_1
      t.string :participant_name_2
      t.string :participant_email_1
      t.string :participant_email_2
      t.string :participant_birth_year_1
      t.string :participant_birth_year_2
      t.string :participant_city_1
      t.string :participant_city_2
      t.string :participant_team_1
      t.string :participant_team_2
      t.string :participant_gender_1
      t.string :participant_gender_2
      t.timestamps
    end
  end
end
