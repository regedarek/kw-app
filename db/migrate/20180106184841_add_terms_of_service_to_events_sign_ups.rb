class AddTermsOfServiceToEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :events_sign_ups, :terms_of_service, :boolean, null: false, default: false
  end
end
