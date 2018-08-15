class AddHeartsCountToHearts < ActiveRecord::Migration[5.0]
  def change
    add_column :mountain_routes, :hearts_count, :integer, default: 0
  end
end
