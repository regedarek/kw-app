class RemoveTermsOfServiceFromEventsSignUps < ActiveRecord::Migration[5.0]
  def change
    remove_column :events_sign_ups, :terms_of_service
  end
end
