class AddInfoAboveCompetionSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :info_above_sign_ups, :text
  end
end
