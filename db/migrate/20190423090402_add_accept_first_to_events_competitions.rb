class AddAcceptFirstToEventsCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :accept_first, :boolean, null: false, default: false
  end
end
