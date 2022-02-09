class AddRulesTextToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :rules_text, :text
  end
end
