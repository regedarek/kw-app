class AddRescuerToEventsSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :rescuer, :boolean, default: false, null: false
  end
end
