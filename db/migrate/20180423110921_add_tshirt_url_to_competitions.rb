class AddTshirtUrlToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :tshirt_url, :string
  end
end
