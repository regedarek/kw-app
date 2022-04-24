class AddPresenceAtToCasePresences < ActiveRecord::Migration[5.2]
  def change
    add_column :case_presences, :presence_date, :date, null: false
    remove_index :case_presences, name: :index_case_presences_on_user_id
    add_index :case_presences, [:user_id, :presence_date], unique: true
  end
end
