class AddEmailTextToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :email_text, :text, null: false, default: 't'
  end
end
