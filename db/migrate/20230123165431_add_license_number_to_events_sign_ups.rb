class AddLicenseNumberToEventsSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :license_number, :integer
  end
end
