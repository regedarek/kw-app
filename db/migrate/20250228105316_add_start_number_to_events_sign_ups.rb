class AddStartNumberToEventsSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :start_number, :integer
  end
end
