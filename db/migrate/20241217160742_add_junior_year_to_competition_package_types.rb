class AddJuniorYearToCompetitionPackageTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :competition_package_types, :junior_year, :integer
  end
end
