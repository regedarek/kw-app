class AddAlertToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :alert, :text
  end
end
