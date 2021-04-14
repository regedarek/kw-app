class AddPassedDateToManagmentResolutions < ActiveRecord::Migration[5.2]
  def change
    add_column :management_resolutions, :passed_date, :date
  end
end
