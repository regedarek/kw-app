class AddMedicalRulesTextToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :medical_rules_text, :text
  end
end
