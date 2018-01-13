class ChangeDefaultCompetitions < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:competitions, :email_text, nil)
  end
end
