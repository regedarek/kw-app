class AddApplicationDateToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :application_date, :date
  end
end
