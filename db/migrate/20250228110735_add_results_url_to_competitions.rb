class AddResultsUrlToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :results_url, :string
  end
end
