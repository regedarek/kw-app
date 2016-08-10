class ChangeDifficulty < ActiveRecord::Migration
  def change
    change_column :routes, :difficulty, :string
  end
end
