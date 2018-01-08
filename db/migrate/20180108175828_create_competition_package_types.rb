class CreateCompetitionPackageTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :competition_package_types do |t|
      t.string :name, null: false
      t.integer :competition_record_id, null: false
      t.integer :cost, null: false
      t.timestamps
    end
  end
end
