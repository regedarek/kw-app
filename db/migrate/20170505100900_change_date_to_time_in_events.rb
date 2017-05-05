class ChangeDateToTimeInEvents < ActiveRecord::Migration[5.0]
  def change
    change_column :events, :event_date, :datetime
  end
end
