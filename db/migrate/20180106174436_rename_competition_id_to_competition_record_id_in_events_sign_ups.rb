class RenameCompetitionIdToCompetitionRecordIdInEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    rename_column :events_sign_ups, :competition_id, :competition_record_id
  end
end
