class AddLicenseNumberToEventSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :events_sign_ups, :participant_license_id_1, :integer
    add_column :events_sign_ups, :participant_license_id_2, :integer
    add_column :events_sign_ups, :participant_country_2, :integer
    add_column :events_sign_ups, :participant_country_1, :integer
    add_column :competitions, :license_id_required, :boolean, null: false, default: false
    add_column :competitions, :country_required, :boolean, null: false, default: false
  end
end
