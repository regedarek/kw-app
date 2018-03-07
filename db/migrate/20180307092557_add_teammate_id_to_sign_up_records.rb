class AddTeammateIdToSignUpRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :teammate_id, :integer
  end
end
