class AddSingleToEventSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :single, :boolean, null: false, default: false
  end
end
