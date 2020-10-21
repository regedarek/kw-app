class AddMeetingTypeToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :meeting_type, :integer, null: false, default: 0
  end
end
