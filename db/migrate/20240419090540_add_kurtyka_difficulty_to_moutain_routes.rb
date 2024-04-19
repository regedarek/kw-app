class AddKurtykaDifficultyToMoutainRoutes < ActiveRecord::Migration[5.2]
  def change
    add_column :mountain_routes, :kurtyka_difficulty, :integer
  end
end
