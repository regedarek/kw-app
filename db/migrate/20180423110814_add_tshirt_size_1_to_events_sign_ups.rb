class AddTshirtSize1ToEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :tshirt_size_1, :string
    add_column :events_sign_ups, :tshirt_size_2, :string
  end
end
