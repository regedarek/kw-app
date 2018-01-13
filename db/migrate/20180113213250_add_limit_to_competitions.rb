class AddLimitToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :limit, :integer, null: false, default: 0
  end
end
