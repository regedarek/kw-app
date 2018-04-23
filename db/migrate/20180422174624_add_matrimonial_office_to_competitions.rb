class AddMatrimonialOfficeToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :matrimonial_office, :boolean, null: false, default: false
  end
end
