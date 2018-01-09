class AddSingleToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :single, :boolean, default: false, null: false
  end
end
