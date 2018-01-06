class AddEditionSymToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :edition_sym, :string, null: false
  end
end
