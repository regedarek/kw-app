class AddClosedToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :closed, :boolean, null: false, default: false
  end
end
