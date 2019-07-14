class ChangeDifficulty < ActiveRecord::Migration[5.0]
  def change
    change_column :routes, :difficulty, :string
  end
end
